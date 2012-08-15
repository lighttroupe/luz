// Copyright 2012 Ian McIntosh

#include "ruby.h"
#include "ruby-ffmpeg.h"

VALUE vModule;
VALUE vFileClass;
int g_ffmpeg_initialized = 0;

static void lazy_init_ffmpeg() {
	if(g_ffmpeg_initialized == 1) { return; }
	printf("ruby-ffmpeg: initializing...\n");
	av_register_all();		// Register all formats and codecs
	g_ffmpeg_initialized = 1;
}

static VALUE FFmpeg_File_width(VALUE self) {
	video_file_t* video_file = NULL;
	Data_Get_Struct(self, video_file_t, video_file);
	return INT2FIX(video_file->av_codec_context->width);
}

static VALUE FFmpeg_File_height(VALUE self) {
	video_file_t* video_file = NULL;
	Data_Get_Struct(self, video_file_t, video_file);
	return INT2FIX(video_file->av_codec_context->height);
}

static VALUE FFmpeg_File_frame_count(VALUE self) {
	video_file_t* video_file = NULL;
	Data_Get_Struct(self, video_file_t, video_file);
	return INT2FIX(video_file->frame_count);
}

static VALUE FFmpeg_File_read_next_frame(VALUE self) {
	video_file_t* video_file = NULL;
	Data_Get_Struct(self, video_file_t, video_file);

	int frame_finished = 0;
	while(av_read_frame(video_file->av_format_context, &(video_file->packet)) >= 0) {
		// Is this a packet from the video stream?
		if(video_file->packet.stream_index == video_file->video_index) {
			// Decode video frame
			avcodec_decode_video2(video_file->av_codec_context, video_file->av_frame, &frame_finished, &(video_file->packet));

			// Did we get a video frame?
			if(frame_finished > 0) {
				sws_scale(video_file->sws_context, (video_file->av_frame->data), video_file->av_frame->linesize, 0, video_file->av_codec_context->height, video_file->av_frame_rgb->data, video_file->av_frame_rgb->linesize);
				return video_file->ruby_string_buffer;
			}
		}
	}
	return Qnil;		// TODO: better to now decode a new frame?
}

static VALUE FFmpeg_File_free(VALUE self) {
	return Qnil;
}

static VALUE FFmpeg_File_new(VALUE klass, VALUE v_file_path) {
	lazy_init_ffmpeg();
	char* file_path = RSTRING_PTR(v_file_path);		// eg. "/dev/video0"

	video_file_t* video_file = ALLOC_N(video_file_t, 1);

	//
	// Open video file
	//
	printf("ruby-ffmpeg: opening %s...\n", file_path);

	if(av_open_input_file(&(video_file->av_format_context), file_path, NULL, 0, NULL) != 0)
		return Qnil;

	if(av_find_stream_info(video_file->av_format_context) < 0)
		return Qnil;

	dump_format(video_file->av_format_context, 0, file_path, 0);		// console debug output

	// Find video stream
	int i;
	for(i=0; i<(video_file->av_format_context->nb_streams); i++) {
		if(video_file->av_format_context->streams[i]->codec->codec_type == CODEC_TYPE_VIDEO) {
			video_file->video_index = i;
			break;
		}
	}
	video_file->av_codec_context = video_file->av_format_context->streams[video_file->video_index]->codec;
	video_file->time_base_per_frame = ((int64_t)(video_file->av_codec_context->time_base.num) * AV_TIME_BASE) / (int64_t)(video_file->av_codec_context->time_base.den);

	// Find decoder for video stream
	video_file->av_codec = avcodec_find_decoder(video_file->av_codec_context->codec_id);
	if(video_file->av_codec == NULL) {
		fprintf(stderr, "Unsupported codec!\n");
		return Qnil;
	}

	if(avcodec_open(video_file->av_codec_context, video_file->av_codec) < 0)
		return Qnil;

	// Get scaling context (eg. YUV=>RGB)
	video_file->sws_context = sws_getContext(video_file->av_codec_context->width, video_file->av_codec_context->height,	// input size
																video_file->av_codec_context->pix_fmt,
																video_file->av_codec_context->width, video_file->av_codec_context->height,	// output size
																//PIX_FMT_YUV420P, SWS_FAST_BILINEAR, 0, 0, 0 );
																PIX_FMT_RGB24, SWS_FAST_BILINEAR, 0, 0, 0 );

	video_file->av_frame = avcodec_alloc_frame();
	video_file->av_frame_rgb = avcodec_alloc_frame();

	int buffer_size = avpicture_get_size(PIX_FMT_RGB24, video_file->av_codec_context->width, video_file->av_codec_context->height);

// TODO: doesn't seem to need to use av_malloc ... uint8_t* buffer = (uint8_t *)av_malloc(numBytes * sizeof(uint8_t));

	char* temp_buffer = ALLOC_N(char, buffer_size);		// rb_str_new() sometimes segfaults with just ""
	video_file->ruby_string_buffer = rb_str_new(temp_buffer, buffer_size);
	rb_gc_register_address(&(video_file->ruby_string_buffer));		// otherwise Ruby will delete our string!

	printf("ruby-ffmpeg: frame size: %d\n", buffer_size);

	// "Assign appropriate parts of buffer to image planes in av_frame_rgb"
	// "Note that av_frame_rgb is an AVFrame, but AVFrame is a superset of AVPicture"
	avpicture_fill((AVPicture *)(video_file->av_frame_rgb), RSTRING_PTR(video_file->ruby_string_buffer), PIX_FMT_RGB24, video_file->av_codec_context->width, video_file->av_codec_context->height);

	video_file->frame_count = video_file->av_format_context->streams[video_file->video_index]->nb_frames;
	if(video_file->frame_count == AV_NOPTS_VALUE) {
		// Alternate method of determining frame count: seek to end and measure duration
		video_file->frame_count = video_file->av_format_context->streams[video_file->video_index]->duration / video_file->time_base_per_frame;
		if(video_file->frame_count == AV_NOPTS_VALUE) {
			// TODO: Seek to end and measure?
		}
	}

	return Data_Wrap_Struct(vFileClass, 0, FFmpeg_File_free, video_file);
}

static VALUE FFmpeg_File_seek_to_frame(VALUE self, VALUE vFrameIndex) {
	video_file_t* video_file = NULL;
	Data_Get_Struct(self, video_file_t, video_file);
	int frame_index = NUM2INT(vFrameIndex);

	if(!(video_file->av_format_context)) {
		return Qfalse;
	}

	int64_t seek_target = (int64_t)(frame_index) * video_file->time_base_per_frame;

	if(av_seek_frame(video_file->av_format_context, -1, seek_target, AVSEEK_FLAG_ANY) < 0) {
		return Qfalse;
	}
	return Qtrue;
}

static VALUE FFmpeg_File_close(VALUE self) {
	return Qnil;
}

// This function is 'main' and is discovered by Ruby automatically due to its name
void Init_ffmpeg() {
	vModule = rb_define_module("FFmpeg");
	vFileClass = rb_define_class_under(vModule, "File", rb_cObject);

	// Setup FFmpeg::File class
	rb_define_singleton_method(vFileClass, "new", &FFmpeg_File_new, 1);
	rb_define_method(vFileClass, "width", &FFmpeg_File_width, 0);
	rb_define_method(vFileClass, "height", &FFmpeg_File_height, 0);
	rb_define_method(vFileClass, "frame_count", &FFmpeg_File_frame_count, 0);
	rb_define_method(vFileClass, "read_next_frame", &FFmpeg_File_read_next_frame, 0);
	rb_define_method(vFileClass, "seek_to_frame", &FFmpeg_File_seek_to_frame, 1);
	rb_define_method(vFileClass, "close", &FFmpeg_File_close, 0);
}
