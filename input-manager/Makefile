all: input-manager

input-manager: *.cc
	gcc -o input-manager *.cc -pthread -lcwiimote -lportmidi -lporttime -I/usr/include/libcwiimote `pkg-config gtkmm-2.4 unique-1.0 liblo sdl bluez --cflags --libs`
