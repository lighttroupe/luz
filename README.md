# Luz 2.0

Fullscreen interactive motion graphics toy builder.

Luz supports vector shapes, animated gifs, sprites, video files.

Luz takes input from wiimotes, MIDI, Wacom tablets, joysticks, gamepads, and generic OpenSoundControl input.

Luz has run hundreds of live venue shows.

Luz is written in Ruby and built on the shoulders of SDL, OpenGL, ffmpeg.

## The Luz Project consists of:

- **Luz 2.0**: fullscreen motion graphics editor and performer (Ruby, OpenGL, SDL, OSC in)
- **Luz Input Manager**: sends live input device data to Luz (C++, Gtk, libwiimote, SDL Input, OSC out)
- **Luz Spectrum Analyzer**: sends live audio information to Luz (C++, Gtk, OpenGL, FFTW, OSC out)

## Video Tutorials

There are no videos yet of the new fullscreen OpenGL interface in Luz 2.0.

Here are some Luz 1.0 video tutorials (all the same concepts apply, only the interface is different):

<http://lighttroupe.com/luz>

# Running Luz

Luz currently only runs on Linux.  (Help is wanted porting it to OSX.)

1. **git clone git@github.com:lighttroupe/luz-next.git**

2. Optionally install dependencies for Input Manager and Spectrum Analyzer: **sudo apt-get install build-essential libasound2-dev libfftw3-dev liblo0-dev libgtkmm-2.4-dev libgtkglextmm-x11-1.2-dev libgl1-mesa-dev libglu1-mesa-dev libx11-dev libxext-dev libxi-dev libsdl1.2-dev libcwiimote-dev libbluetooth-dev libportmidi-dev liblo-dev libunique-dev**

3. Optionally run **make** in the root directory to build Input Manager and Spectrum Analyzer.

4. Optionally run **./build** in utils/webcam for the Webcam plugin.

5. Optionally run **./build** in utils/video-file for the Video plugin.

6. Optionally enhance your laptop's touchpad (see below).

7. **ruby1.9.1 luz.rb gui/editor.luz**

## Enhance Your Touchpad

Your touchpad will work like a mouse by default, but you can get high-definition absolute-positioned data out of it, which is ideal for "playing" your visual instrument.  (Absolute means you tap on one side, get X=0.2, tap on the other, get X=0.8 instantly.)

<https://help.ubuntu.com/community/SynapticsTouchpad#Enabling_SHMConfig_in_order_to_get_synclient_debug_output>

After you've rebooted, Input Manager will show a "Touchpad" input and will send *Touchpad / X*, *Touchpad / Y* and *Touchpad / Pressure* to Luz automatically.
