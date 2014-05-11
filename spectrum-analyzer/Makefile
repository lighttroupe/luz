all: spectrum-analyzer

spectrum-analyzer: *.cc
	gcc -o spectrum-analyzer *.cc -lasound -lm -lstdc++ `pkg-config --cflags --libs fftw3 gl glu liblo gtkmm-2.4 gtkglextmm-1.2`
