all: body-tracker

body-tracker: *.cc
	gcc -o body-tracker *.cc -IGL -Iglh -I/usr/include/ni -lOpenNI -lm -lglut `pkg-config --cflags --libs gl glu liblo gtkmm-2.4 gtkglextmm-1.2`
