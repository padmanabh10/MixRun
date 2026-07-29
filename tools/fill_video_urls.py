
from __future__ import annotations
import argparse,json,os,re,sys,time,urllib.parse,urllib.request,urllib.error

CATALOG=os.path.join("lib","data","game_data.dart")
SEARCH="https://www.googleapis.com/youtube/v3/search"

ENTRY=re.compile(
r"""(?P<head>id:\s*'(?P<id>[^']+)',.*?nameEn:\s*"(?P<name>[^"]*)",.*?url:\s*"(?P<url>[^"]*)",)(?P<tail>\s*\n\s*videoUrl:\s*"(?P<video>[^"]*)",)?""",
re.S)

CONTEXT={
"states":"India geography for kids",
"history":"Indian history documentary for students",
"culture":"Indian culture explained for kids",
"arts":"Indian traditional art explained",
"heroes":"biography for students India",
"base":"explained for kids"
}

GOOD={
"TED-Ed","TED Ed","National Geographic","Nat Geo Kids","SciShow",
"SciShow Kids","CrashCourse","Crash Course Kids","BBC Earth",
"Smithsonian Channel","Free School","Homeschool Pop",
"Peekaboo Kidz","MinuteEarth","History","Simple History",
"Geography Now","PBS Eons","PBS Terra","FuseSchool",
"Learning Junction","The Dr. Binocs Show","Kids Learning Tube",
"Incredible India","National Geographic India"
}

BAD={
"song","lyrics","music","audio","reaction","status","shorts",
"gaming","minecraft","roblox","edit","meme","prank","trailer",
"movie","scene","cover","remix","nightcore","8d"
}

class QuotaExhausted(RuntimeError): pass

def load(p):
    return open(p,encoding="utf-8").read()

def category(txt):
    m=re.search(r"category:\s*ElementCategory\.(\w+),",txt)
    return m.group(1) if m else "base"

def score(item):
    s=0
    sn=item["snippet"]
    t=sn["title"].lower()
    d=sn.get("description","").lower()
    c=sn["channelTitle"]
    cl=c.lower()
    if c in GOOD: s+=120
    if "kids" in cl: s+=40
    if "education" in d: s+=20
    for w in ("explained","documentary","history","geography","science","learn","facts","for kids"):
        if w in t: s+=15
    for w in BAD:
        if w in t or w in d or w in cl:
            s-=150
    return s

def search_video(name,ctx,key):
    params={
        "part":"snippet",
        "q":f"{name} {ctx}",
        "type":"video",
        "videoEmbeddable":"true",
        "videoDuration":"medium",
        "safeSearch":"strict",
        "relevanceLanguage":"en",
        "regionCode":"IN",
        "maxResults":"15",
        "key":key
    }
    url=SEARCH+"?"+urllib.parse.urlencode(params)
    try:
        with urllib.request.urlopen(url,timeout=20) as r:
            payload=json.load(r)
    except urllib.error.HTTPError as e:
        body=e.read().decode()
        if e.code==403 and "quota" in body.lower():
            raise QuotaExhausted()
        return None
    items=payload.get("items",[])
    items.sort(key=score,reverse=True)
    for it in items:
        vid=it.get("id",{}).get("videoId")
        if vid:
            return f"https://www.youtube.com/watch?v={vid}"
    params["videoDuration"]="long"
    url=SEARCH+"?"+urllib.parse.urlencode(params)
    try:
        with urllib.request.urlopen(url,timeout=20) as r:
            payload=json.load(r)
    except:
        return None
    items=payload.get("items",[])
    items.sort(key=score,reverse=True)
    for it in items:
        vid=it.get("id",{}).get("videoId")
        if vid:
            return f"https://www.youtube.com/watch?v={vid}"
    return None

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--api-key",default=os.environ.get("YOUTUBE_API_KEY"))
    ap.add_argument("--catalog",default=CATALOG)
    ap.add_argument("--limit",type=int,default=90)
    ap.add_argument("--dry-run",action="store_true")
    ap.add_argument("--refill",action="store_true")
    ap.add_argument("--report",action="store_true")
    a=ap.parse_args()

    txt=load(a.catalog)
    ms=list(ENTRY.finditer(txt))
    miss=[m for m in ms if not (m.group("video") or "").strip()]
    print(len(ms),"elements,",len(miss),"missing")
    if a.report:return
    if not a.api_key:
        print("Missing API key");return
    targets=ms if a.refill else miss
    targets=targets[:a.limit]
    edits=[]
    filled=0
    try:
        for i,m in enumerate(targets,1):
            name=m.group("name")
            ctx=CONTEXT.get(category(m.group(0)),"explained for kids")
            v=search_video(name,ctx,a.api_key)
            if not v:
                print(i,name,"no result")
                continue
            print(i,name,v)
            edits.append((m.end("head"),m.end(),'\n      videoUrl: "'+v+'",'))
            filled+=1
            time.sleep(0.1)
    except QuotaExhausted:
        print("Quota exhausted.")
    if a.dry_run:return
    for s,e,l in reversed(edits):
        txt=txt[:s]+l+txt[e:]
    with open(a.catalog,"w",encoding="utf-8") as f:
        f.write(txt)
    print("Filled",filled)

if __name__=="__main__":
    main()
