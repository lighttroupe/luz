#!/usr/bin/env ruby
require 'mkmf'
dir_config('ffmpeg');
raise 'Missing needed development libraries (avformat)' unless have_library('avformat', 'avformat_open_input')
raise 'Missing needed development libraries (swscale)' unless have_library('swscale', 'sws_getContext')
create_makefile('ffmpeg');
