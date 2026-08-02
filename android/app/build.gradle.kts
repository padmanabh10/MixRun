import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Apply the Firebase Google Services plugin only when its config file exists,
// so the project keeps building before Firebase has been set up. Drop
// google-services.json into android/app/ to enable accounts.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

// AdMob application id, injected into AndroidManifest.xml as ${admobAppId}.
// Kept out of source control,  supply the real id one of these ways:
//   * `admob.appId=ca-app-pub-XXX~YYY` in android/local.properties (gitignored)
//   * `-Padmob.appId=ca-app-pub-XXX~YYY` on the Gradle command line
//   * an ADMOB_APP_ID environment variable (for CI)
// Falls back to Google's public test app id, so a fresh clone builds and shows
// test ads without any AdMob account.
val admobAppId: String = run {
    val local = Properties()
    val localFile = rootProject.file("local.properties")
    if (localFile.exists()) {
        localFile.inputStream().use { local.load(it) }
    }
    local.getProperty("admob.appId")
        ?: project.findProperty("admob.appId") as String?
        ?: System.getenv("ADMOB_APP_ID")
        ?: "ca-app-pub-3940256099942544~3347511713"
}

// Release signing material, kept out of source control in android/key.properties
// (see README). MixRun is side-loaded and updates itself in place, and Android
// refuses to install an update signed with a different key than the installed
// build — so this keystore must outlive every release. Back it up; losing it
// means no installed copy can ever be updated again.
//
// Absent, the release build falls back to the debug key so a fresh clone still
// builds. Such a build must never be distributed: the debug key is generated
// per machine, so the next machine produces un-installable updates.
val keystoreProperties: Properties? = run {
    val file = rootProject.file("key.properties")
    if (!file.exists()) return@run null
    Properties().apply { file.inputStream().use { load(it) } }
}

android {
    namespace = "com.mixrun.mixrun"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mixrun.mixrun"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Firebase Auth/Firestore require minSdk 23+.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    signingConfigs {
        if (keystoreProperties != null) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystoreProperties != null) {
                signingConfigs.getByName("release")
            } else {
                // No keystore on this machine: sign with the debug key so the
                // build still succeeds. Do not ship the resulting APK.
                logger.warn("key.properties not found — signing release with the DEBUG key. Do not distribute this APK.")
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
