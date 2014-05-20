# Luz 2.0

Fullscreen interactive motion graphics toy builder.

Luz supports vector shapes, animated gifs, sprites, video files.

Luz takes input from wiimotes, MIDI, Wacom tablets, joysticks, gamepads, and generic OpenSoundControl input.

Luz has run hundreds of live venue shows.

Luz is written in Ruby and built on the shoulders of SDL, OpenGL, ffmpeg.

## Video Tutorials

There are no videos yet of the new fullscreen OpenGL interface in Luz 2.0.

Some Luz 1.0 videos:

<http://lighttroupe.com/luz>

## The Luz Project consists of:

- **Luz 2.0**: fullscreen motion graphics editor and performer (Ruby, OpenGL, SDL, OSC in)
- **Luz Input Manager**: sends live input device data to Luz (C++, Gtk, libwiimote, SDL Input, OSC out)
- **Luz Spectrum Analyzer**: sends live audio information to Luz (C++, Gtk, OpenGL, FFTW, OSC out)

# Getting Luz

Luz currently only runs on Linux.  (Help is wanted porting it to OSX.)

1. Clone this repository.

2. Install dependencies as described in README.

3. Optionally run 'make' in the root directory to build Input Manager (input-manager/input-manager) and Spectrum Analyzer (spectrum-analyzer/spectrum-analyzer).

4. Optionally run the ./build scripts in utils/webcam for the Webcam plugin.

5. Optionally run the ./build scripts in utils/video-file for the Video plugin.

6. Optionally enhance your touchpad with high definition data and absolute positioning (see below).

7. **ruby1.9.1 luz.rb gui/editor.luz**


# Enhance Your Synaptic Touchpad

Your touchpad will work like a mouse by default but you can get high definition absolutely-positioned data out of it.  (Tap on one side, get X=0.2, tap on the other, get X=0.8 instantly.)

    https://help.ubuntu.com/community/SynapticsTouchpad#Enabling_SHMConfig_in_order_to_get_synclient_debug_output

When this has worked, after you've rebooted, Input Manager will show a "Touchpad" input and will send *Touchpad / X*, *Touchpad / Y* and *Touchpad / Pressure* automatically.

Section "InputClass"
        Identifier "enable synaptics SHMConfig"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Option "SHMConfig" "on"
EndSection
