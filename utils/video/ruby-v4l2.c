
#include "ruby.h"
#include "ruby-v4l2.h"

VALUE vModule;
VALUE vCameraClass;

static VALUE Video4Linux2_Camera_free(void* p);

static VALUE Video4Linux2_Camera_width(VALUE self) {
	//printf("Video4Linux2_Camera_width\n");
	camera_t* camera = NULL;
	Data_Get_Struct(self, camera_t, camera);
	return INT2FIX(camera->format.fmt.pix.width);
}

static VALUE Video4Linux2_Camera_height(VALUE self) {
	//printf("Video4Linux2_Camera_height\n");
	camera_t* camera = NULL;
	Data_Get_Struct(self, camera_t, camera);
	return INT2FIX(camera->format.fmt.pix.height);
}

static VALUE Video4Linux2_Camera_data(VALUE self) {
	//printf("Video4Linux2_Camera_data\n");
	camera_t* camera = NULL;
	Data_Get_Struct(self, camera_t, camera);

	//printf("before reading data... %d\n", RSTRING(camera->ruby_string)->len);
	//ssize_t size = v4l2_read(camera->fd, RSTRING(camera->ruby_string)->ptr, RSTRING(camera->ruby_string)->len);
	ssize_t size = v4l2_read(camera->fd, camera->buffer, camera->buffer_size);

	return rb_str_new(camera->buffer, camera->buffer_size);
}

/// + Video4Linux2::Camera#new
static VALUE Video4Linux2_Camera_new(VALUE klass) {
	//printf("Video4Linux2_Camera_new\n");

	int fd = -1;
	int ret = -1;
	errno = 0;

	camera_t* camera = malloc(sizeof(camera_t));

	// Start V4L2 using libv4l2 wrapper
	camera->format.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
	camera->format.fmt.pix.width = 320;
	camera->format.fmt.pix.height = 240;
	camera->format.fmt.pix.pixelformat = V4L2_PIX_FMT_RGB24;
	camera->format.fmt.pix.field = V4L2_FIELD_ANY;

	camera->fd = v4l2_open("/dev/video0", O_RDWR);
	//printf("fd: %d\n", camera->fd);

	// Set format
	ret = v4l2_ioctl(camera->fd, VIDIOC_S_FMT, &(camera->format));
	if(ret != 0) {
		printf("ioctl(fd, VIDIOC_S_FMT, ...): %d, errno: %d\n", ret, errno);
	}

	camera->buffer_size = camera->format.fmt.pix.height * camera->format.fmt.pix.width * 3;		// RGB24 = 3 bytes per pixel (24/8)

	//void* raw_buffer = malloc(camera->buffer_size);
	//camera->ruby_string = rb_str_new(raw_buffer, camera->buffer_size);
	//if(RSTRING(camera->ruby_string)->ptr == raw_buffer) {
	//	printf("Pointers are equal..\n");
	//}
	//printf("length of Ruby String is %d, buffer size %d (should be the same)\n", RSTRING(camera->ruby_string)->len, camera->buffer_size);

	camera->buffer = ALLOC_N(char, camera->buffer_size);
	//printf("buffer: %p\n", camera->buffer);

	return Data_Wrap_Struct(vCameraClass, 0, Video4Linux2_Camera_free, camera);
}

/// - Video4Linux2::Camera#initialize
static VALUE Video4Linux2_Camera_initialize(VALUE self) {
	printf("Video4Linux2_Camera_initialize\n");
	return self;
}

static VALUE Video4Linux2_Camera_free(void* p) {
	//printf("Video4Linux2_Camera_free\n");

	if ( NULL != p ) {
		//free((void*)p);
	}
}

void Init_video4linux2() {
	vModule = rb_define_module("Video4Linux2");
	vCameraClass = rb_define_class_under(vModule, "Camera", rb_cObject);

	// Setup Camera class
	rb_define_singleton_method(vCameraClass, "new", &Video4Linux2_Camera_new, 0);
	rb_define_method(vCameraClass, "initialize", &Video4Linux2_Camera_initialize, 0);
	rb_define_method(vCameraClass, "width", &Video4Linux2_Camera_width, 0);
	rb_define_method(vCameraClass, "height", &Video4Linux2_Camera_height, 0);
	rb_define_method(vCameraClass, "data", &Video4Linux2_Camera_data, 0);
}
