# docker-multimedia

## _Multimedia apps in docker_

All multimedia apps (FFMPEG, ImageMagick, AV1 encoders ect...) in a docker container.

## Table of contents

## Features

- FFMPEG
- Handbrake cli
- ImageMagick

## Requirements

### Software requirements

| Software | Minimum | Recommended |
| -------- | ------- | ----------- |
| Linux    | Any     | Any         |
| Docker   | 19.x    | 20.x        |
| Make     | 4.x     | 4.x         |

### Hardware requirements

|       Hardware        |  Minimum  |   Recommended    |
| :-------------------: | :-------: | :--------------: |
|          CPU          |   2c/2t   |      6c/12t      |
| Instruction set (x86) | x86-64-v2 |    x86-64-v3     |
| Instruction set (ARM) |   armv8   |      armv8       |
|          RAM          |   8 GB    |      32 GB       |
|          GPU          |     -     | Hardware enc/dec |
|      Disk space       |   4 GB    |      16 GB       |
|       Internet        |  10 Mbps  |     100 Mbps     |

## How to use docker-multimedia

Clone this repository

```bash
git clone --recurse-submodules https://github.com/bensuperpc/docker-multimedia.git
```

### Build with docker

```bash
make archlinux
```

Test the container:

```bash
make archlinux.test
```

## Start the container

Now you can start the container, it will mount the current directory in the container.

```bash
./docker-multimedia.sh <command>
```

## Update submodules and base archlinux image

```bash
make update
```

## Video commands examples

### FFMPEG options

|    Option     |      default      |        Example        |                                        Description                                         |
| :-----------: | :---------------: | :-------------------: | :----------------------------------------------------------------------------------------: |
|      -vf      |         -         |   -vf scale=1920:-1   |                                Downscale the video to 1080p                                |
|      -g       |         ?         |         -g 60         | Set the keyframe interval of x frames, lower value increase quality but increase file size |
|   -pix_fmt    | Depends on source |   -pix_fmt yuv420p    |           Set the pixel format, yuv420p for 8-bit, yuv420p10le for 10-bit ect...           |
|     -crf      |         -         |           -           |                  Constant Rate Factor, **options depend on the encoder**                   |
|    -preset    |         -         |           -           |                 Set the encoding speed, **options depend on the encoder**                  |
|     -tune     |         -         |           -           |                  Set the encoding tune, **options depend on the encoder**                  |
|     -c:v      |         -         |     -c:v libx265      |                Set the video codec, **options depend on installed codecs**                 |
|     -c:a      |         -         |       -c:a copy       |                Set the audio codec, **options depend on installed codecs**                 |
|     -c:s      |         -         |       -c:s copy       |               Set the subtitle codec, **options depend on installed codecs**               |
|   -threads    |         0         |      -threads 8       |                           Set the number of threads, 0 for auto                            |
|     -map      |         -         |        -map 0         |                             Map the input stream to the output                             |
| -map_metadata |         -         |    -map_metadata 0    |                               Map the metadata to the output                               |
| -map_chapters |         -         |    -map_chapters 0    |                               Map the chapters to the output                               |
|   -fps_mode   |       auto        | -fps_mode passthrough |                    Set the frame rate mode, passthrough, cfr, vfr, auto                    |
|   -loglevel   |         -         |    -loglevel error    |               Set the log level, error, warning, info, verbose, debug, trace               |
| -hide_banner  |         -         |     -hide_banner      |                                      Hide the banner                                       |
|      -y       |         -         |          -y           |                           Overwrite output files without asking                            |

### Convert video to AV1 CRF (SVT-AV1)

This table shows the most common options for SVT-AV1, like the preset, crf, and svtav1-params.

**For svtav1-params each option is separated by a colon `:`, option and value are separated by `=`, like `tune=0:enable-qm=1:qm-min=0`.**

|     Option      | default |  Min/Max  |              Example              |                       Description                        |
| :-------------: | :-----: | :-------: | :-------------------------------: | :------------------------------------------------------: |
|     -preset     |    4    | -preset 4 |               0-12                |          0 for slowest, 12 for fastest encoding          |
|      -crf       |   18    |  -crf 30  |               0-63                |    Constant Rate Factor, lower value increase quality    |
| -svtav1-params  |    -    |     -     | -svtav1-params tune=0:enable-qm=1 |                 SVT-AV1 specific options                 |
|      tune       |    1    |    0-1    |       -svtav1-params tune=0       | 0 for subjective quality, 1 for objective quality (PSNR) |
|    enable-qm    |    0    |    0-1    |    -svtav1-params enable-qm=1     |               Enable quantization matrices               |
|     qm-min      |    8    |   0-15    |      -svtav1-params qm-min=0      |               Minimum quantization matrix                |
|     qm-max      |   15    |   0-15    |     -svtav1-params qm-max=10      |               Maximum quantization matrix                |
| enable-overlays |    0    |    0-1    | -svtav1-params enable-overlays=1  |                     Enable overlays                      |
|   film-grain    |    0    |   0-12    |    -svtav1-params film-grain=8    |               Add film grain to the video                |

More information about the options can be found in the [SVT-AV1 documentation](
https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/Parameters.md?ref_type=heads)

Example of encoding CRF for very high quality (Maybe little overkill, preset 4 and crf 20 is a good start for 1080p).

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -c:v libsvtav1 -preset 2 -crf 14 -svtav1-params tune=0:enable-qm=1:qm-min=0:qm-max=8 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

- **-preset 1**: i recommend to use 4-6 for good quality and speed, 3 or lower for better quality but it **really** slow (~2x slower per lower step, for minimal gain).
- **-crf 14**: CRF 20-24 is a good start, 14 for very high quality bit bigger file size.
- **tune=0**: Enable subjective quality, 1 for objective quality (PSNR).
- **enable-qm=1**: Enable quantization matrices.
- **qm-min=0**: Minimum quantization matrix, reduce it for lower compression in certain zones, the _8_ default is little too high, 0-4 is a good start.
- **qm-max=8**: Maximum quantization matrix, increase it for higher compression in certain zones, the _15_ default is little too high, 8-12 is a good start.

With **AV1AN**, it usefull if you have move than 16 threads, SVT-AV1 is not well optimized for over 16 threads, AV11AN encode the video in parallel **per scene**.

```bash
./docker-multimedia.sh av1an -i input.mkv --encoder svt-av1 --video-params "--rc 0 --crf 16 --preset 1 --tune 0 --enable-qm=1 --qm-min=0 --qm-max=8" --audio-params "-c:a copy" -o temp_output.mkv
```

Copy metadata and chapters:

```bash
ffmpeg -i temp_output.mkv -i input.mkv -map 0 -map_metadata 1 -map_chapters 1 -c copy output.mkv
```

Optional for AV1AN:

- Add `--video-filter "scale=1920:-1"` to downscale the video to 1080p
- Add `--keyint 60` in video-params to set the keyframe interval to 60 frames (every 1 seconds at 60fps), lower value increase quality but increase file size

### Convert video to AV1 CRF(AOM)

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -c:v libaom-av1 -crf 18 -cpu-used 3 -row-mt 1 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Convert video to AV1 CRF (Rav1e)

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -y -c:v librav1e -crf 18 -speed 3 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Convert video to h265 CRF (x265)

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -y -c:v libx265 -crf 18 -preset slower -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Convert video to h265 ABR 2 pass and scale to 720p (x265)

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -y -c:v libx265 -preset slow -vf scale=1280:-1 -b:v 2000k -minrate 500k -maxrate 6000k -bufsize 12000k -pass 1 -an -f null /dev/null && ffmpeg -i input.mkv -preset slow -vf scale=1280:-1 -c:v libx265 -b:v 2000k -minrate 500k -maxrate 6000k -bufsize 12000k -pass 2 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Convert video to h264 CRF (x264)

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -c:v libx264 -crf 26 -preset slow -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Convert video FFV1 (v3)

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -c:v ffv1 -level 3 -coder 1 -context 1 -g 1 -slices 4 -slicecrc 1 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Convert video FFV1 (v3) 2 pass

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -c:v ffv1 -level 3 -coder 1 -context 1 -g 1 -slices 4 -slicecrc 1 -pass 1 -an -f null /dev/null && ffmpeg -i input.mkv -c:v ffv1 -level 3 -coder 1 -context 1 -g 1 -slices 4 -slicecrc 1 -pass 2 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Get SSIM

SSIM Y: For luma (Y) channel, 0-1, 1 is perfect match
SSIM U: For chrominance (U) channel, 0-1, 1 is perfect match
SSIM V: For chrominance (V) channel, 0-1, 1 is perfect match
SSIM All: Average of YUV, 0-1, 1 is perfect match

```bash
./docker-multimedia.sh ffmpeg -i output.mkv -i input.mkv -lavfi ssim -f null –
```

### Get PSNR

PSNR Y: For luma (Y) channel, in dB higher is better
PSNR U: For chrominance (U) channel, in dB higher is better
PSNR V: For chrominance (V) channel, in dB higher is better
PSNR All: Average of YUV, in dB higher is better

```bash
./docker-multimedia.sh ffmpeg -i output.mkv -i input.mkv -lavfi psnr -f null –
```

### Get VMAF

VMAF score, higher is better

```bash
./docker-multimedia.sh ffmpeg -i output.mkv -i input.mkv -lavfi libvmaf -f null –
```

Output into a json file

```bash
./docker-multimedia.sh ffmpeg -i video1.mp4 -i video2.mp4 -lavfi libvmaf="log_path=vmaf.json:log_fmt=json" -f null -
```

### Cut video without re-encoding

Extract from 125s to 200s

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -ss 125 -t 75 -copyts -map_metadata 0 -vcodec copy -acodec copy out.mkv
```

Extract from 125s to 150s

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -ss 125 -to 150 -c copy -copyts -map_metadata 0 -vcodec copy -acodec copy out.mkv
```

### Import watermark

Import watermark at 10:10 from the top left corner

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -i watermark.png -filter_complex "overlay=10:10" -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mp4
```

### Change video speed

Speed up the video by 2x

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -vf "setpts=0.5*PTS" -af "atempo=2.0" -map_metadata 0 output.mp4
```

Change the video frame rate to 30fps (2x slower if the original is 60fps)

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -filter:v fps=fps=30 -map_metadata 0 output.mp4
```

### Convert video to gif

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -vf "fps=24,scale=480:-1:flags=lanczos" -c:v gif -map_metadata 0 output.gif
```

### Add vintage look effect to video and play it with ffplay

```bash
ffplay -i input.mp4 -vf "curves=vintage,noise=alls=30:allf=t+u,hue=s=0.7,eq=contrast=0.85:brightness=-0.1:saturation=0.7,gblur=sigma=1.5,colorbalance=rm=0.2:gm=0.1:bm=-0.2,vignette"
```

- **curves=vintage**: Add a vintage look
- **noise=alls=30:allf=t+u**: Add noise
- **hue=s=0.7**: Reduces saturation
- **eq=contrast=0.85:brightness=-0.01:saturation=0.7**: Adjust contrast, brightness and saturation
- **gblur=sigma=1.5**: Add a gaussian blur
- **colorbalance=rm=0.2:gm=0.1:bm=-0.2**: Adjust color balance to sepia tone
- **vignette**: Add a vignette

## Image commands examples

### Convert images png to webp (lossless)

```bash
./docker-multimedia.sh find . -name "*.png" | parallel -eta cwebp -metadata all -lossless -exact -z 9 "{}" -o "{.}.webp" && find . -name "*.png" -exec sh -c 'touch -r "${0%.*}.png" "${0%.*}.webp"' "{}" ';'
```

### Get difference between two images

```bash
./docker-multimedia.sh compare -metric AE input1.png input2.webp null:
```

Or with ImageMagick

```bash
./docker-multimedia.sh magick input1.png ppm:- | magick input2.webp ppm:- | diff -q - <(magick input2.webp ppm:-)
```

##  Audio commands examples

### Generate audio spectrogram with sox

You can generate a spectrogram with sox, for example with a flac file to detect "fake" flac files.

```bash
./docker-multimedia.sh sox input_audio.flac -n spectrogram -o output_spectrogram.png
```

_Add `-t flac` if the input file is not recognized as flac._

### Increase audio volume without re-encoding

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -af "volume=2.0" -c:v copy -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mp4
```

### Convert audio

| Audio lib  | Max bitrate | Extension |
| :--------: | :---------: | :-------: |
| libmp3lame |   320kbps   |    mp3    |
|    aac     |   250kbps   |    m4a    |
|  libopus   |   250kbps   |   opus    |
|    flac    |  lossless   |   flac    |
| pcm_s16le  |    16bit    |    wav    |

Convert audio to mp3

```bash
./docker-multimedia.sh ffmpeg -i input.flac -c:a libmp3lame -b:a 320k output.mp3
```

Convert audio to lossy or "fake" flac

```bash
./docker-multimedia.sh ffmpeg -i output.mp3 output.flac
```

Remove noise from audio

```bash
./docker-multimedia.sh ffmpeg -i input.mp3 -af "highpass=f=200, lowpass=f=3000" output.mp3
```

Convert to compatible audio format for garry's mod

```bash
./docker-multimedia.sh ffmpeg -i input.mp3 -c:a pcm_s16le -b:a 128k -ar 44100 -ac 2 output.wav
```

## Metadata commands examples

### Get metadata from audio or video file

```bash
./docker-multimedia.sh ffprobe -v quiet -print_format json -show_format -show_streams input.mp4
```

### Youtube-dlp

Download audio from youtube video without re-encoding:

```bash
./docker-multimedia.sh yt-dlp -f bestaudio --extract-audio --embed-thumbnail --embed-metadata --embed-chapters --output "%(title)s.%(ext)s" "https://www.youtube.com/watch?v=video_playlist_id"
```

Download video from youtube video without re-encoding:

```bash
./docker-multimedia.sh yt-dlp -f "bestvideo+(251/mergeall[format_id~=251-])" --audio-multistreams --sub-langs "all,-live_chat" --embed-chapters --embed-metadata --merge-output-format mkv --output "%(title)s.%(ext)s" "https://www.youtube.com/watch?v=video_id"
```

## Useful links

- [FFMPEG](https://ffmpeg.org/)
- [ImageMagick](https://imagemagick.org/)
- [Simple SVT-AV1 Beginner Guide](https://gist.github.com/BlueSwordM/86dfcb6ab38a93a524472a0cbe4c4100)
- [CommonQuestions SVT-AV1](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/CommonQuestions.md)
- [Vintage look with ffmpeg](https://ottverse.com/create-vintage-videos-using-ffmpeg/)
- [FFMPEG filters](https://ffmpeg.org/ffmpeg-filters.html)
- [FFMPEG Lame](https://trac.ffmpeg.org/wiki/Encode/MP3)
- [Encoding Animation with SVT-AV1: A Deep Dive](https://wiki.x266.mov/blog/svt-av1-deep-dive)

## License

[MIT](LICENSE)
