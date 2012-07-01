#!/usr/bin/env ruby
require 'mkmf'

dir_config('avformat');

if have_library('avformat', 'av_open_input_file') then
  create_makefile('avformat');
else
  raise 'No avformat library found.'
end
