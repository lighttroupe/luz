# Copyright 2012 Ian McIntosh

#ifndef RUBY_V4L2_H
#define RUBY_V4L2_H

#ifdef __cplusplus
extern "C" {
#endif

#include <linux/videodev2.h>		// pure V4l2 library file
#include <libv4l2.h>						// wrapper providing RGB color conversion
#include <fcntl.h>							// for O_RDWR
#include <errno.h>
#include <malloc.h>

/// data types
typedef struct {
		int fd;
		int buffer_size;
		VALUE ruby_string;
		char* buffer;
		struct v4l2_format format;
} camera_t;

/// function prototypes
extern void Init_video4linux2();

/*
/// helper macros
#define albool2rbbool(b) ((b)?(Qtrue):(Qfalse))

#define RARRAY2ARRAY(rbary, ary, n, convf) \
VALUE ___v; int ___c;\
for(___c=0;___c<n;___c++){\
 ___v=rb_ary_entry(rbary,___c);\
 ary[___c]=convf(___v);}

#define ARRAY2RARRAY(ary, rbary, n, convf) \
int ___c; \
for(___c=0;___c<n;___c++){\
 rb_ary_push(rbary, convf(ary[___c]));}\
*/

#ifdef __cplusplus
}
#endif

#endif
