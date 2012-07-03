// Copyright 2012 Ian McIntosh

#ifndef RUBY_FFMPEG_H
#define RUBY_FFMPEG_H

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>

#include <fcntl.h>							// for O_RDWR
#include <errno.h>

typedef struct {
	int fd;
	AVFormatContext *av_format_context;
	AVCodecContext *av_codec_context;
	AVCodec *av_codec;
	int video_index;							// index of the first video stream in a file
	AVPacket packet;
	AVFrame *av_frame;
	struct SwsContext *sws_context;
	AVFrame *av_frame_rgb;
	VALUE ruby_string_buffer;			// We use a ruby String variable to pass frames around
} video_file_t;

extern void Init_avformat();

#endif
