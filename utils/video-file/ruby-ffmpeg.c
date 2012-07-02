// Copyright 2012 Ian McIntosh

#include "ruby.h"
#include "ruby-ffmpeg.h"

VALUE vModule;
VALUE vFileClass;
int g_ffmpeg_initialized = 0;

static void init_ffmpeg() {
	if(g_ffmpeg_initialized == 1) { return; }
	printf("ruby-ffmpeg: initializing...\n");
	av_register_all();		// Register all formats and codecs
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
	video_file_t* video_file = NULL;
	Data_Get_Struct(self, video_file_t, video_file);

	AVFrame picture;

	int frame_finished = 0;
	while(av_read_frame(video_file->pFormatCtx, &(video_file->packet)) >= 0) {
		// Is this a packet from the video stream?
		if(video_file->packet.stream_index == video_file->video_index) {
			// Decode video frame
			avcodec_decode_video2(video_file->pCodecCtx, video_file->pFrame, &frame_finished, &(video_file->packet));

			// Did we get a video frame?
			if(frame_finished > 0) {
				sws_scale(video_file->sws_context, (video_file->pFrame->data), video_file->pFrame->linesize, 0, video_file->pCodecCtx->height, video_file->pFrameRGB->data, video_file->pFrameRGB->linesize);
				return video_file->ruby_string_buffer;
			}
		}
	}
	return Qnil;
}

static VALUE FFmpeg_File_free(VALUE self) {
	return Qnil;
}

static VALUE FFmpeg_File_new(VALUE klass, VALUE v_file_path) {
	init_ffmpeg();		// lazy init
	char* file_path = RSTRING_PTR(v_file_path);		// eg. "/dev/video0"

	video_file_t* video_file = ALLOC_N(video_file_t, 1);

	//
	// Open video file
	//
	printf("ruby-ffmpeg: opening %s...\n", file_path);

	if(av_open_input_file(&(video_file->pFormatCtx), file_path, NULL, 0, NULL) != 0)
		return Qnil;

	if(av_find_stream_info(video_file->pFormatCtx) < 0)
		return Qnil;

	dump_format(video_file->pFormatCtx, 0, file_path, 0);		// console debug output

	// Find video stream
	int i;
	for(i=0; i<(video_file->pFormatCtx->nb_streams); i++) {
		if(video_file->pFormatCtx->streams[i]->codec->codec_type == CODEC_TYPE_VIDEO) {
			video_file->video_index = i;
			break;
		}
	}
	video_file->pCodecCtx = video_file->pFormatCtx->streams[video_file->video_index]->codec;

	// Find decoder for video stream
	video_file->pCodec = avcodec_find_decoder(video_file->pCodecCtx->codec_id);
	if(video_file->pCodec == NULL) {
		fprintf(stderr, "Unsupported codec!\n");
		return Qnil;
	}

	if(avcodec_open(video_file->pCodecCtx, video_file->pCodec) < 0)
		return Qnil;

	// Get scaling context (eg. YUV=>RGB)
	video_file->sws_context = sws_getContext(video_file->pCodecCtx->width, video_file->pCodecCtx->height,	// input size
																video_file->pCodecCtx->pix_fmt,
																video_file->pCodecCtx->width, video_file->pCodecCtx->height,	// output size
																//PIX_FMT_YUV420P, SWS_FAST_BILINEAR, 0, 0, 0 );
																PIX_FMT_RGB24, SWS_FAST_BILINEAR, 0, 0, 0 );

	video_file->pFrame = avcodec_alloc_frame();
	video_file->pFrameRGB = avcodec_alloc_frame();

	int buffer_size = avpicture_get_size(PIX_FMT_RGB24, video_file->pCodecCtx->width, video_file->pCodecCtx->height);

// TODO: doesn't seem to need to use av_malloc ... uint8_t* buffer = (uint8_t *)av_malloc(numBytes * sizeof(uint8_t));

	char* temp_buffer = ALLOC_N(char, buffer_size);		// rb_str_new() sometimes segfaults with just ""
	video_file->ruby_string_buffer = rb_str_new(temp_buffer, buffer_size);
	rb_gc_register_address(&(video_file->ruby_string_buffer));		// otherwise Ruby will delete our string!

	printf("ruby-ffmpeg: frame size: %d\n", buffer_size);

	// "Assign appropriate parts of buffer to image planes in pFrameRGB"
	// "Note that pFrameRGB is an AVFrame, but AVFrame is a superset of AVPicture"
	avpicture_fill((AVPicture *)(video_file->pFrameRGB), RSTRING_PTR(video_file->ruby_string_buffer), PIX_FMT_RGB24, video_file->pCodecCtx->width, video_file->pCodecCtx->height);

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
