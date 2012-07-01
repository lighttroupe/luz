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
	VALUE ruby_string_buffer;			// We use a ruby String variable to pass frames around

	AVFormatContext *pFormatCtx;
	AVCodecContext  *pCodecCtx;
	AVCodec         *pCodec;

	AVFrame         *pFrame; 
	AVFrame         *pFrameRGB;
	AVPacket        packet;

} video_file_t;

extern void Init_avformat();

#endif
