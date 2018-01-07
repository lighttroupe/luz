# Luz 2

Fullscreen interactive motion graphics toy builder!

[![Screenshot](http://41.media.tumblr.com/accf5bff3d48056e959747db5fed666a/tumblr_nh8q2pWPCs1te3fw8o1_540.png)](http://lighttroupe.tumblr.com/)

Just add music, input devices, a projector, and you've got an addiction.

<http://lighttroupe.tumblr.com>

Create 'actors' using: vector shapes, animated gifs, sprites, webcams and videos.

Every actor gets unlimited effects that layer and combine in delightful ways.

Every setting of every effect can be animated to time or beats, or connected to any button or axis of input devices.

Luz supports wiimotes, joysticks, gamepads, Wacom tablets, and MIDI devices.

Luz can also be driven by OpenSoundControl sending software.

Luz has provided interactive visuals at hundreds of venues, festivals, and house parties!

Befriend people: "Have you tried this yet?" and hand them control of the projected visuals.

Luz is written in Ruby and offloads all the heavy pixel pushing to ffmpeg, OpenGL, and your modern graphics card.

The Luz 2.0 interface was designed in Inkscape and the source SVGs are in the gui/images directory.

[![Code Climate](https://codeclimate.com/github/lighttroupe/luz.png)](https://codeclimate.com/github/lighttroupe/luz)

## The Luz Project consists of:

- **Luz 2**: fullscreen motion graphics editor and performer (Ruby, OpenGL, SDL, OSC input)
- **Luz Input Manager**: sends live input device data to Luz (C++, Gtk, libwiimote, SDL Input, OSC out)
- **Luz Spectrum Analyzer**: sends live audio information to Luz (C++, Gtk, OpenGL, FFTW, OSC out)

## Video Tutorials

Here are some Luz 1 videos and tutorials (all the same concepts apply, only the interface is different):

<https://www.youtube.com/user/superlighttube/videos?flow=grid&sort=da&view=0>

# Installing Luz

Open a terminal and copy and paste in the following commands:

1. **sudo apt-get install git ruby ruby-dev ruby-pango libsdl2-dev libglw1-mesa-dev freeglut3-dev ruby-rmagick**
2. **sudo gem install ruby-sdl2 syck opengl glu glut**
3. **git clone https://github.com/lighttroupe/luz.git**
4. **cd luz**
5. Optionally run **./build.sh** in utils/webcam for the Webcam plugin.
6. Optionally run **./build.sh** in utils/video_file for the Video plugin.
7. **./go**

Luz currently only runs on Linux.  (Help is welcome porting it to OSX and Windows.)

## Running Input Manager and Spectrum Analyzer

1. Run **sudo apt-get install build-essential libx11-dev libxext-dev libxi-dev libbluetooth-dev libportmidi-dev libcwiid-dev liblo-dev libunique-dev libgtkmm-2.4-dev libasound2-dev libfftw3-dev libgtkmm-2.4-dev libgtkglextmm-x11-1.2-dev libgl1-mesa-dev libglu1-mesa-dev**

2. Run **make** in the root directory to build Input Manager and Spectrum Analyzer.

3. Ctrl-F9 and Ctrl-F10 from within Luz launch the apps.
