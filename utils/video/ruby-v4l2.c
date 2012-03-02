// Copyright 2012 Ian McIntosh

#include "ruby.h"
#include "ruby-v4l2.h"

VALUE vModule;
VALUE vCameraClass;

static VALUE Video4Linux2_Camera_width(VALUE self) {
	camera_t* camera = NULL;
	Data_Get_Struct(self, camera_t, camera);
	return INT2FIX(camera->format.fmt.pix.width);
}

static VALUE Video4Linux2_Camera_height(VALUE self) {
	camera_t* camera = NULL;
	Data_Get_Struct(self, camera_t, camera);
	return INT2FIX(camera->format.fmt.pix.height);
}

static VALUE Video4Linux2_Camera_data(VALUE self) {
	camera_t* camera = NULL;
	Data_Get_Struct(self, camera_t, camera);

	// Read frame data right into the String's memory (ptr) and return it
	ssize_t size = v4l2_read(camera->fd, RSTRING(camera->ruby_string_buffer)->ptr, RSTRING(camera->ruby_string_buffer)->len);

	if(size == -1)
		return Qnil;
	else
		return camera->ruby_string_buffer;
}

static VALUE Video4Linux2_Camera_free(void* p) {
	// TODO
}

static VALUE Video4Linux2_Camera_new(VALUE klass) {
	int fd = -1;
	int ret = -1;

	camera_t* camera = malloc(sizeof(camera_t));

	// Start V4L2 using RedHat's libv4l2 wrapper, which provides RGB conversion, if needed
	// TODO: make this selectable
	camera->fd = v4l2_open("/dev/video0", O_RDWR | O_NONBLOCK);
	//printf("fd: %d\n", camera->fd);

	// Apply video format
	camera->format.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	camera->format.fmt.pix.width = 320;
	camera->format.fmt.pix.height = 240;
	camera->format.fmt.pix.pixelformat = V4L2_PIX_FMT_RGB24;
	camera->format.fmt.pix.field = V4L2_FIELD_ANY;
	ret = v4l2_ioctl(camera->fd, VIDIOC_S_FMT, &(camera->format));
	if(ret != 0) {
		printf("ioctl(fd, VIDIOC_S_FMT, ...): %d, errno: %d\n", ret, errno);
	}

	// Allocate a ruby String to hold frame data
	int buffer_size = camera->format.fmt.pix.height * camera->format.fmt.pix.width * 3;		// RGB24 = 24/8 = 3 bytes per pixel
	char* temp_buffer = ALLOC_N(char, buffer_size);		// rb_str_new() sometimes segfaults with just ""
	camera->ruby_string_buffer = rb_str_new(temp_buffer, buffer_size);
	rb_gc_register_address(&(camera->ruby_string_buffer));		// otherwise Ruby will delete our string!

	return Data_Wrap_Struct(vCameraClass, 0, Video4Linux2_Camera_free, camera);
}

// This function is 'main' and is discovered by Ruby automatically due to its name
void Init_video4linux2() {
	vModule = rb_define_module("Video4Linux2");
	vCameraClass = rb_define_class_under(vModule, "Camera", rb_cObject);

	// Setup Camera class
	rb_define_singleton_method(vCameraClass, "new", &Video4Linux2_Camera_new, 0);
	rb_define_method(vCameraClass, "width", &Video4Linux2_Camera_width, 0);
	rb_define_method(vCameraClass, "height", &Video4Linux2_Camera_height, 0);
	rb_define_method(vCameraClass, "data", &Video4Linux2_Camera_data, 0);
}
