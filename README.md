# Luz 2.0

Fullscreen interactive motion graphics toy builder.  Luz is pure Ruby and built on the shoulders of SDL, OpenGL, among others.

Luz supports vector shapes, animated gifs, sprites, video files.

Luz takes input from wiimotes, MIDI, Wacom tablets, joysticks, gamepads, and OSC.

Luz has run hundreds of live venue shows.

## Shader Snippets

Luz builds custom OpenGL shader programs on the fly.

## Video Tutorials

There are no videos yet of the new fullscreen OpenGL interface in Luz 2.0.

Some Luz 1.0 videos:

<http://lighttroupe.com/luz>

## The Luz Project consists of:

- **Luz 2.0**: fullscreen motion graphics editor and performer (Ruby, OpenGL, SDL)
- **Luz Audio Player**: plays music and sends song progress percentage to Luz (Ruby, GStreamer)
- **Luz Input Manager**: sends live input device data to Luz (C++, Gtk+, XOrg API, libwiimote, SDL Input)
- **Luz Spectrum Analyzer**: sends audio information to Luz (C++, OpenGL, FFTW)

# Getting Luz

Luz currently only runs on Linux.  Help is wanted porting it to OSX.

1. Clone this repository.

2. Install dependencies as described in README.

3. Optionally run 'make' in the root directory to build Input Manager and Spectrum Analyzer

4. Optionally run the ./build scripts in utils/webcam, utils/video-file, and utils/chipmunk.

5. ruby1.9.1 luz.rb gui/editor.luz
