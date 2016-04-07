all: input-manager

input-manager: *.cc
	gcc -o input-manager *.cc -DSUPPORT_TABLET -DSUPPORT_MIDI -pthread -lportmidi -lporttime -lstdc++ -lXi -lX11 -I/usr/include/xorg/ `pkg-config gtkmm-2.4 unique-1.0 liblo bluez --cflags --libs`
