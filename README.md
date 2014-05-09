# Luz 2.0

A live motion graphics editor and performer.

<http://createdigitalmotion.com/2011/03/luz-live-motion-graphics-controlled-by-anything-free-on-linux-and-now-with-dmx>

## Video Tutorials

<http://lighttroupe.com/luz>

## The Luz Project consists of:

- **Luz 2.0**: fullscreen motion graphics editor and performer (Ruby, OpenGL)
- **Luz Audio Player**: plays music and sends song progress percentage to Luz (Ruby, GStreamer)
- **Luz Input Manager**: sends live input device data to Luz (C++, Gtk+, XOrg API, libwiimote, SDL Input)
- **Luz Spectrum Analyzer**: sends audio information to Luz (C++, OpenGL, FFTW)
- **Luz Body Tracker**: sends motion-tracked human data to Luz (C++, OpenGL, OpenNI+NITE)

# Getting Luz

Luz currently only runs on Linux.  Help is wanted porting it to OSX.

1. Clone this repository.

2. Install dependencies as described in README.

3. Optionally run 'make' in the root directory to build Input Manager and Spectrum Analyzer

4. Optionally run the ./build scripts in utils/webcam, utils/video-file, and utils/chipmunk.

5. ruby1.9.1 luz.rb gui/editor.luz
