from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
import yt_dlp
import uvicorn
import httpx
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/info")
def get_video_info(url: str):
    ydl_opts = {
        'quiet': True,
        'no_warnings': True,
        'skip_download': True,
    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            
            audio_formats = []
            video_formats = []
            
            for f in info.get('formats', []):
                # Filter out m3u8 playlists, we want direct HTTP links for Dio downloader
                if f.get('protocol') in ['m3u8.native', 'm3u8']:
                    continue
                    
                # Audio only
                if f.get('vcodec') == 'none' and f.get('acodec') != 'none':
                    audio_formats.append({
                        'formatId': f.get('format_id'),
                        'url': f.get('url'),
                        'ext': f.get('ext'),
                        'qualityLabel': f"{int(f.get('abr', 0))}kbps" if f.get('abr') else "Audio"
                    })
                # Muxed (Video + Audio)
                elif f.get('vcodec') != 'none' and f.get('acodec') != 'none':
                    video_formats.append({
                        'formatId': f.get('format_id'),
                        'url': f.get('url'),
                        'ext': f.get('ext'),
                        'resolution': f.get('resolution'),
                        'qualityLabel': f.get('format_note') or f.get('resolution') or "Video"
                    })
            
            # If no muxed streams are found, grab video-only streams as fallback
            if not video_formats:
                for f in info.get('formats', []):
                     if f.get('vcodec') != 'none' and f.get('acodec') == 'none':
                        video_formats.append({
                            'formatId': f.get('format_id'),
                            'url': f.get('url'),
                            'ext': f.get('ext'),
                            'resolution': f.get('resolution'),
                            'qualityLabel': f.get('format_note') or f.get('resolution') or "Video"
                        })

            return {
                'title': info.get('title'),
                'duration': info.get('duration'),
                'thumbnailUrl': info.get('thumbnail'),
                'uploader': info.get('uploader'),
                'audioStreams': audio_formats,
                'videoStreams': video_formats
            }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/proxy")
async def proxy_stream(url: str):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    }
    try:
        client = httpx.AsyncClient(follow_redirects=True)
        req = client.build_request("GET", url, headers=headers)
        r = await client.send(req, stream=True)
        
        response_headers = {}
        if "content-length" in r.headers:
            response_headers["content-length"] = r.headers["content-length"]
        if "content-type" in r.headers:
            response_headers["content-type"] = r.headers["content-type"]
            
        async def stream_generator():
            try:
                async for chunk in r.aiter_bytes(chunk_size=1024 * 64):
                    yield chunk
            finally:
                await r.aclose()
                await client.aclose()
                
        return StreamingResponse(stream_generator(), headers=response_headers)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
def health_check():
    return {"status": "ok", "message": "Backend is running flawlessly!"}

@app.get("/")
def root():
    return {"message": "YT Downloader Backend is actively running on your laptop! Go to the mobile app to download videos."}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
