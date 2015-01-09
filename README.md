# Luz 2

Fullscreen interactive motion graphics toy builder.

<http://lighttroupe.tumblr.com>

Luz supports vector shapes, animated gifs, sprites, video files.

Luz takes input from wiimotes, MIDI, Wacom tablets, joysticks, gamepads, and generic OpenSoundControl input.

Luz has run hundreds of live venue shows.

Luz is written in Ruby and uses SDL, OpenGL, ffmpeg for the heavy lifting.

The Luz 2.0 interface is designed in Inkscape.  Find the source SVGs in the gui/images directory.

[![Code Climate](https://codeclimate.com/github/lighttroupe/luz-next.png)](https://codeclimate.com/github/lighttroupe/luz-next)

## The Luz Project consists of:

- **Luz 2**: fullscreen motion graphics editor and performer (Ruby, OpenGL, SDL, OSC in)
- **Luz Input Manager**: sends live input device data to Luz (C++, Gtk, libwiimote, SDL Input, OSC out)
- **Luz Spectrum Analyzer**: sends live audio information to Luz (C++, Gtk, OpenGL, FFTW, OSC out)

## Video Tutorials

Here are some Luz 1 video tutorials (all the same concepts apply, only the interface is different):

<http://lighttroupe.com/luz>

# Running Luz

Luz currently only runs on Linux.  (Help is wanted porting it to OSX and Windows.)

1. **sudo apt-get install git ruby1.9.1 libsdl-ruby1.9.1 libopengl-ruby1.9.1 ruby-pango**

2. **git clone https://github.com/lighttroupe/luz-next.git**

3. **sudo gem1.9.1 install rmagick**

4. Optionally run **./build** in utils/webcam for the Webcam plugin.

5. Optionally run **./build** in utils/video_file for the Video plugin.

6. Optionally enhance your laptop's touchpad (see below).

7. **ruby1.9.1 luz.rb gui/editor.luz**


## Running Input Manager and Spectrum Analyzer

1. Install dependencies: **sudo apt-get install build-essential libasound2-dev libfftw3-dev liblo0-dev libgtkmm-2.4-dev libgtkglextmm-x11-1.2-dev libgl1-mesa-dev libglu1-mesa-dev libx11-dev libxext-dev libxi-dev libsdl1.2-dev libcwiimote-dev libbluetooth-dev libportmidi-dev liblo-dev libunique-dev xserver-xorg-input-synaptics-dev**

2. Run **make** in the root directory to build Input Manager and Spectrum Analyzer.

3. Ctrl-F9 and Ctrl-F10 from within Luz launch the apps.

## Enhance Your Touchpad

Your touchpad will work like a mouse by default, but you can get high-definition absolute-positioned data out of it, which is wonderful for "playing" your visual instrument.  (Absolute means you tap on one side, get X=0.2, tap on the other, get X=0.8 instantly.)

<https://help.ubuntu.com/community/SynapticsTouchpad#Enabling_SHMConfig_in_order_to_get_synclient_debug_output>

**Reboot** and then Input Manager should show a "Touchpad" input and will send *Touchpad / X*, *Touchpad / Y* and *Touchpad / Pressure* to Luz automatically.
