# Luz 2

[![Screenshot](http://41.media.tumblr.com/accf5bff3d48056e959747db5fed666a/tumblr_nh8q2pWPCs1te3fw8o1_540.png)](http://lighttroupe.tumblr.com/)

Fullscreen interactive motion graphics toy builder.

<http://lighttroupe.tumblr.com>

Create your visuals using vector shapes, animated gifs, sprites, webcams and videos.

Connect unlimited input devices: Luz supports wiimotes, MIDI, Wacom tablets, joysticks, gamepads, and OpenSoundControl input.

Luz has provided interactive visuals at hundreds of venues, festivals, and house parties.

Luz is written in Ruby and offloads all the heavy pixel pushing to ffmpeg, OpenGL, and your GPU.

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

1. open terminal
2. sudo apt-get install git ruby ruby-dev ruby-pango libsdl2-dev libglw1-mesa-dev freeglut3-dev ruby-rmagick
3. sudo gem install ruby-sdl2 syck opengl glu glut
4. git clone https://github.com/lighttroupe/luz-next.git
5. cd luz-next
6. git checkout sdl2
7. Optionally run **./build** in utils/webcam for the Webcam plugin.
8. Optionally run **./build** in utils/video_file for the Video plugin.
9. Optionally enhance your laptop's touchpad (see below).
10. ./go

## Running Input Manager and Spectrum Analyzer

1. Install dependencies: **sudo apt-get install build-essential libasound2-dev libfftw3-dev liblo0-dev libgtkmm-2.4-dev libgtkglextmm-x11-1.2-dev libgl1-mesa-dev libglu1-mesa-dev libx11-dev libxext-dev libxi-dev libsdl1.2-dev libcwiimote-dev libbluetooth-dev libportmidi-dev liblo-dev libunique-dev xserver-xorg-input-synaptics-dev**

2. Run **make** in the root directory to build Input Manager and Spectrum Analyzer.

3. Ctrl-F9 and Ctrl-F10 from within Luz launch the apps.

## Enhance Your Touchpad

Your touchpad will work like a mouse by default, but you can get high-definition absolute-positioned data out of it, which is wonderful for "playing" your visual instrument.  (Absolute means you tap on one side, get X=0.2, tap on the other, get X=0.8 instantly.)

<https://help.ubuntu.com/community/SynapticsTouchpad#Enabling_SHMConfig_in_order_to_get_synclient_debug_output>

**Reboot** and then Input Manager should show a "Touchpad" input and will send *Touchpad / X*, *Touchpad / Y* and *Touchpad / Pressure* to Luz automatically.

## Unofficial 64 bit DEB packages from openartist.org

http://openartist.org/debian/trusty64/luz-next_20141027-1_amd64.deb
