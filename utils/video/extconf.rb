#!/usr/bin/env ruby
require 'mkmf'

dir_config('video4linux2');

if have_library('v4l2', 'v4l2_open') then
  create_makefile('video4linux2');
else
  raise 'No v4l2 library found.'
end
