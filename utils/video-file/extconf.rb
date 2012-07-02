#!/usr/bin/env ruby
require 'mkmf'

dir_config('ffmpeg');

if have_library('avformat', 'av_open_input_file') &&
	have_library('swscale', 'sws_getContext')
	create_makefile('ffmpeg');
else
	raise 'Missing needed development libraries (avformat, swscale).'
end
