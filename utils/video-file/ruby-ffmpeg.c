// Copyright 2012 Ian McIntosh

#include "ruby.h"
#include "ruby-ffmpeg.h"

VALUE vModule;
VALUE vFileClass;
int g_ffmpeg_initialized = 0;

static void init_ffmpeg() {
	if(g_ffmpeg_initialized == 1) { return; }
	printf("Initializing FFmpeg...\n");
	// Register all formats and codecs
	av_register_all();

	g_ffmpeg_initialized = 1;
}

static VALUE FFmpeg_File_width(VALUE self) {
	video_file_t* video_file = NULL;
	Data_Get_Struct(self, video_file_t, video_file);
	return INT2FIX(video_file->width);
}

static VALUE FFmpeg_File_height(VALUE self) {
	video_file_t* video_file = NULL;
	Data_Get_Struct(self, video_file_t, video_file);
	return INT2FIX(video_file->height);
}

static VALUE FFmpeg_File_data(VALUE self) {
	return Qnil;
}

static VALUE FFmpeg_File_free(VALUE self) {
	return Qnil;
}

static VALUE FFmpeg_File_new(VALUE klass, VALUE v_file_path) {
	init_ffmpeg();
	char* file_path = RSTRING_PTR(v_file_path);		// eg. "/dev/video0"

	video_file_t* video_file = ALLOC_N(video_file_t, 1);

/*
	AVFormatContext *pFormatCtx;
	AVCodecContext  *pCodecCtx;
	AVCodec         *pCodec;
	AVFrame         *pFrame; 
	AVFrame         *pFrameRGB;
	AVPacket        packet;
*/

	//
	// Open video file
	//
	if(av_open_input_file(&(video_file->pFormatCtx), file_path, NULL, 0, NULL) != 0)
		return Qnil; // Couldn't open file

	video_file->width = 1;
	video_file->height = 5;

	//
	// ?
	//
	return Data_Wrap_Struct(vFileClass, 0, FFmpeg_File_free, video_file);
}

static VALUE FFmpeg_File_close(VALUE self) {
	return Qnil;
}

// This function is 'main' and is discovered by Ruby automatically due to its name
void Init_avformat() {
	vModule = rb_define_module("FFmpeg");
	vFileClass = rb_define_class_under(vModule, "File", rb_cObject);

	// Setup FFmpeg::File class
	rb_define_singleton_method(vFileClass, "new", &FFmpeg_File_new, 1);
	rb_define_method(vFileClass, "width", &FFmpeg_File_width, 0);
	rb_define_method(vFileClass, "height", &FFmpeg_File_height, 0);
	rb_define_method(vFileClass, "data", &FFmpeg_File_data, 0);
	rb_define_method(vFileClass, "close", &FFmpeg_File_close, 0);
}
