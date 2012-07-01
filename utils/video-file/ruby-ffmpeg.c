// Copyright 2012 Ian McIntosh

#include "ruby.h"
#include "ruby-ffmpeg.h"

VALUE vModule;
VALUE vFileClass;
int g_ffmpeg_initialized = 0;

static void init_ffmpeg() {
	if(g_ffmpeg_initialized == 1) { return; }
	printf("ruby-ffmpeg: initializing...\n");
	// Register all formats and codecs
	av_register_all();

	g_ffmpeg_initialized = 1;
}

static VALUE FFmpeg_File_width(VALUE self) {
	video_file_t* video_file = NULL;
	Data_Get_Struct(self, video_file_t, video_file);
	return INT2FIX(video_file->pCodecCtx->width);
}

static VALUE FFmpeg_File_height(VALUE self) {
	video_file_t* video_file = NULL;
	Data_Get_Struct(self, video_file_t, video_file);
	return INT2FIX(video_file->pCodecCtx->height);
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
	printf("ruby-ffmpeg: opening %s...\n", file_path);

	if(av_open_input_file(&(video_file->pFormatCtx), file_path, NULL, 0, NULL) != 0)
		return Qnil;

	if(av_find_stream_info(video_file->pFormatCtx) < 0)
		return Qnil;

	dump_format(video_file->pFormatCtx, 0, file_path, 0);

	int video_index = -1;
	int i;
	for(i=0; i<(video_file->pFormatCtx->nb_streams); i++) {
		if(video_file->pFormatCtx->streams[i]->codec->codec_type == CODEC_TYPE_VIDEO) {
			video_index = i;
			break;
		}
	}

	video_file->pCodecCtx = video_file->pFormatCtx->streams[video_index]->codec;

	// Find the decoder for the video stream
	video_file->pCodec = avcodec_find_decoder(video_file->pCodecCtx->codec_id);
	if(video_file->pCodec == NULL) {
		fprintf(stderr, "Unsupported codec!\n");
		return Qnil;
	}

	if(avcodec_open(video_file->pCodecCtx, video_file->pCodec) < 0)
		return Qnil;

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
