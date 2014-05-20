# Luz 2.0

Fullscreen interactive motion graphics toy builder.

Luz supports vector shapes, animated gifs, sprites, video files.

Luz takes input from wiimotes, MIDI, Wacom tablets, joysticks, gamepads, and generic OpenSoundControl input.

Luz has run hundreds of live venue shows.

Luz is written in Ruby and built on the shoulders of SDL, OpenGL, ffmpeg.

## Video Tutorials

There are no videos yet of the new fullscreen OpenGL interface in Luz 2.0.

Some Luz 1.0 video tutorials (all the same concepts apply, only the interface is different):

<http://lighttroupe.com/luz>

## The Luz Project consists of:

- **Luz 2.0**: fullscreen motion graphics editor and performer (Ruby, OpenGL, SDL, OSC in)
- **Luz Input Manager**: sends live input device data to Luz (C++, Gtk, libwiimote, SDL Input, OSC out)
- **Luz Spectrum Analyzer**: sends live audio information to Luz (C++, Gtk, OpenGL, FFTW, OSC out)

# Getting Luz

Luz currently only runs on Linux.  (Help is wanted porting it to OSX.)

1. **git clone git@github.com:lighttroupe/luz-next.git**

2. Optionally install dependencies for Input Manager and Spectrum Analyzer: **sudo apt-get install build-essential libasound2-dev libfftw3-dev liblo0-dev libgtkmm-2.4-dev libgtkglextmm-x11-1.2-dev libgl1-mesa-dev libglu1-mesa-dev libx11-dev libxext-dev libxi-dev libsdl1.2-dev libcwiimote-dev libbluetooth-dev libportmidi-dev liblo-dev libunique-dev**

3. Optionally run **make** in the root directory to build Input Manager and Spectrum Analyzer.

4. Optionally run the ./build scripts in utils/webcam for the Webcam plugin.

5. Optionally run the ./build scripts in utils/video-file for the Video plugin.

6. Optionally enhance your touchpad with high definition data and absolute positioning (see below).

7. **ruby1.9.1 luz.rb gui/editor.luz**



# Enhance Your Synaptic Touchpad

Your touchpad will work like a mouse by default but you can get high definition absolutely-positioned data out of it.  (Tap on one side, get X=0.2, tap on the other, get X=0.8 instantly.)

<https://help.ubuntu.com/community/SynapticsTouchpad#Enabling_SHMConfig_in_order_to_get_synclient_debug_output>

After you've rebooted, Input Manager will show a "Touchpad" input and will send *Touchpad / X*, *Touchpad / Y* and *Touchpad / Pressure* automatically.
