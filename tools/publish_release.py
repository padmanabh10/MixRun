"""Publish the `config/app_version` document that tells installed copies of
MixRun a new APK exists (see lib/data/app_update_repository.dart).

MixRun is side-loaded, so this document is the *only* channel by which a phone
in someone's pocket learns about a release. Typing it into the Firebase console
by hand invites the two mistakes that matter: a build number that doesn't match
the APK you actually shipped, and a download URL that 404s. This script reads
the build number straight out of pubspec.yaml and refuses to publish a URL it
can't fetch.

Writes go through the Admin SDK, which bypasses the `allow write: if false` in
firestore.rules. That needs credentials:

    # once, from the Firebase console:
    #   Project settings -> Service accounts -> Generate new private key
    set GOOGLE_APPLICATION_CREDENTIALS=C:\\path\\to\\serviceAccount.json

    pip install firebase-admin

Usage:

    # publish the version currently in pubspec.yaml
    python tools/publish_release.py --url https://.../mixrun-1.1.0.apk \\
        --notes "New Heroes level\\nFaster canvas"

    # see the document without writing anything
    python tools/publish_release.py --url https://... --dry-run

    # force everyone below build 2 to update before they can play
    python tools/publish_release.py --url https://... --min-version-code 2

Publish the APK *before* running this: the moment the document lands, every
launch that checks in will be pointed at that URL.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PUBSPEC = os.path.join(ROOT, "pubspec.yaml")
FIREBASERC = os.path.join(ROOT, ".firebaserc")

COLLECTION = "config"
DOCUMENT = "app_version"

# `version: 1.1.0+2` -> name 1.1.0, code 2.
VERSION = re.compile(r"^version:\s*(?P<name>[^\s+]+)\+(?P<code>\d+)\s*$", re.M)


def pubspec_version():
    """The version name and build number declared in pubspec.yaml."""
    with open(PUBSPEC, encoding="utf-8") as handle:
        match = VERSION.search(handle.read())
    if match is None:
        sys.exit(
            "pubspec.yaml has no `version: <name>+<build>` line. Pass "
            "--version-name and --version-code explicitly."
        )
    return match.group("name"), int(match.group("code"))


def default_project():
    """The Firebase project from .firebaserc, so the id isn't repeated here."""
    try:
        with open(FIREBASERC, encoding="utf-8") as handle:
            return json.load(handle)["projects"]["default"]
    except (OSError, KeyError, json.JSONDecodeError):
        return None


def check_url(url):
    """Confirm the APK is actually downloadable, and report its size.

    A document pointing at a dead link is worse than no document: the player
    gets a prompt, taps Update now, and lands on a 404 with the old build still
    installed. Redirects are followed, since release hosts habitually use them.
    """
    request = urllib.request.Request(url, method="HEAD")
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            size = response.headers.get("Content-Length")
            return True, _describe(response.status, size)
    except urllib.error.HTTPError as error:
        # Some hosts reject HEAD but serve GET perfectly well. Retry before
        # calling it broken.
        if error.code in (403, 405, 501):
            try:
                with urllib.request.urlopen(url, timeout=30) as response:
                    size = response.headers.get("Content-Length")
                    return True, _describe(response.status, size)
            except (urllib.error.URLError, OSError) as retry_error:
                return False, str(retry_error)
        return False, f"HTTP {error.code} {error.reason}"
    except (urllib.error.URLError, OSError) as error:
        return False, str(error)


def _describe(status, size):
    if not size:
        return f"HTTP {status}, size unknown"
    return f"HTTP {status}, {int(size) / 1024 / 1024:.1f} MB"


def build_entry(args, version_name, version_code):
    """The per-platform map stored under the release document."""
    entry = {
        "versionCode": version_code,
        "versionName": version_name,
        "minVersionCode": args.min_version_code,
        "downloadUrl": args.url,
    }
    notes = args.notes
    if args.notes_file:
        with open(args.notes_file, encoding="utf-8") as handle:
            notes = handle.read().strip()
    if notes:
        # Written as-is into the prompt, so `\n` in a shell argument should
        # become a real line break.
        entry["notes"] = notes.replace("\\n", "\n")
    return entry


def publish(project, platform, entry):
    """Merge [entry] into the release document under its platform key."""
    try:
        import firebase_admin
        from firebase_admin import firestore
    except ImportError:
        sys.exit("firebase-admin is not installed. Run: pip install firebase-admin")

    if not os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        sys.exit(
            "GOOGLE_APPLICATION_CREDENTIALS is not set. Download a service "
            "account key from the Firebase console (Project settings -> "
            "Service accounts) and point that variable at it."
        )

    firebase_admin.initialize_app(options={"projectId": project})
    db = firestore.client()
    # merge=True so publishing Android never clears an ios entry, and vice versa.
    db.collection(COLLECTION).document(DOCUMENT).set({platform: entry}, merge=True)


def main():
    parser = argparse.ArgumentParser(
        description="Publish the MixRun release document to Firestore.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--url", required=True, help="public download URL of the APK")
    parser.add_argument(
        "--notes", help="what's new blurb shown in the prompt; \\n breaks lines"
    )
    parser.add_argument("--notes-file", help="read the blurb from a file instead")
    parser.add_argument(
        "--min-version-code",
        type=int,
        default=0,
        help="oldest build still allowed to play; 0 (default) forces nobody",
    )
    parser.add_argument(
        "--version-name", help="defaults to the name in pubspec.yaml"
    )
    parser.add_argument(
        "--version-code",
        type=int,
        help="defaults to the build number in pubspec.yaml",
    )
    parser.add_argument(
        "--platform",
        default="android",
        choices=("android", "ios"),
        help="which entry of the document to write (default: android)",
    )
    parser.add_argument(
        "--project", default=default_project(), help="Firebase project id"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="print the document and exit without writing",
    )
    parser.add_argument(
        "--skip-url-check",
        action="store_true",
        help="publish even if the download URL can't be fetched",
    )
    parser.add_argument(
        "-y", "--yes", action="store_true", help="don't ask for confirmation"
    )
    args = parser.parse_args()

    if not args.project:
        sys.exit("No Firebase project. Pass --project or add one to .firebaserc.")

    name, code = pubspec_version()
    version_name = args.version_name or name
    version_code = args.version_code if args.version_code is not None else code

    if args.min_version_code > version_code:
        sys.exit(
            f"--min-version-code {args.min_version_code} is newer than the build "
            f"being published ({version_code}), which would lock out every "
            "player including this release."
        )

    if args.skip_url_check:
        print("! skipping the download check")
    else:
        ok, detail = check_url(args.url)
        print(f"{'ok  ' if ok else 'FAIL'} {args.url} ({detail})")
        if not ok:
            sys.exit(
                "The APK isn't downloadable. Upload it first, or pass "
                "--skip-url-check if you're certain."
            )

    entry = build_entry(args, version_name, version_code)
    print(f"\n{args.project} :: {COLLECTION}/{DOCUMENT}")
    print(json.dumps({args.platform: entry}, indent=2, ensure_ascii=False))

    if args.dry_run:
        print("\ndry run: nothing written")
        return

    print(
        f"\nEvery installed build below {version_code} will be prompted to "
        "update, and it takes up to AppUpdateRepository.cacheTtl (6h) for a "
        "correction to reach a phone that already checked."
    )
    if not args.yes and input("Publish? [y/N] ").strip().lower() not in ("y", "yes"):
        sys.exit("cancelled")

    publish(args.project, args.platform, entry)
    print(f"published {version_name}+{version_code}")


if __name__ == "__main__":
    main()
