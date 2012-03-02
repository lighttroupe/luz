// Copyright 2012 Ian McIntosh

#ifndef RUBY_V4L2_H
#define RUBY_V4L2_H

#include <linux/videodev2.h>		// pure V4l2 library file
#include <libv4l2.h>						// wrapper providing RGB color conversion
#include <fcntl.h>							// for O_RDWR
#include <errno.h>

typedef struct {
	int fd;
	struct v4l2_format format;
	VALUE ruby_string_buffer;			// We use a ruby String variable to pass frames around
} camera_t;

extern void Init_video4linux2();

#endif
