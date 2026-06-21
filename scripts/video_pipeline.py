import os
import sys
import json
import logging
import time
from moviepy.editor import ImageClip, TextClip, CompositeVideoClip, AudioFileClip, ColorClip

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger("VideoPipeline")

class VideoGenerator:
    def __init__(self, output_dir="/storage/processed_assets"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)

    def render_with_retry(self, payload, retries=3):
        for i in range(retries):
            try:
                return self.render_video(payload)
            except Exception as e:
                logger.error(f"Attempt {i+1} failed: {e}")
                if i == retries - 1: raise
                time.sleep(2)

    def render_video(self, payload):
        vid_id = payload.get('id', 'temp')
        text = payload.get('text', 'No Text')
        audio_path = payload.get('audio_path')
        bg_image = payload.get('bg_image')
        format_type = payload.get('format', '16:9')
        
        if not audio_path or not os.path.exists(audio_path):
            raise ValueError(f"Audio file missing: {audio_path}")

        size = (1920, 1080) if format_type == '16:9' else (1080, 1920)
        audio = AudioFileClip(audio_path)
        duration = audio.duration
        
        # Background
        if bg_image and os.path.exists(bg_image):
            bg = ImageClip(bg_image).set_duration(duration).resize(height=size[1])
            if bg.w > size[0]:
                bg = bg.crop(x_center=bg.w/2, width=size[0])
        else:
            bg = ColorClip(size=size, color=(20, 20, 20)).set_duration(duration)
        
        # Text Overlay
        txt = TextClip(text, fontsize=60, color='white', font='Arial-Bold', 
                      size=(size[0]*0.9, None), method='caption')
        txt = txt.set_duration(duration).set_position(('center', size[1]*0.7))
        
        # Composite and Write
        video = CompositeVideoClip([bg, txt], size=size).set_audio(audio)
        out_path = os.path.join(self.output_dir, f"{vid_id}.mp4")
        
        video.write_videofile(out_path, fps=24, codec='libx264', audio_codec='aac', 
                             threads=4, logger=None)
        
        return out_path

if __name__ == "__main__":
    try:
        data = json.loads(sys.argv[1])
        gen = VideoGenerator()
        result_path = gen.render_with_retry(data)
        print(json.dumps({"status": "success", "path": result_path}))
    except Exception as e:
        logger.error(f"Render failed: {e}")
        print(json.dumps({"status": "error", "message": str(e)}))
        sys.exit(1)
