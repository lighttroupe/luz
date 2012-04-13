#!/usr/bin/env ruby
require 'mkmf'

dir_config('openal');

if have_func('snprintf', 'stdio.h') and
   have_library('openal', 'alGetError') and  
   have_library('alut', 'alutGetErrorString') and
   have_library('vorbis', 'ogg_sync_init') and
   have_library('vorbisfile', 'ov_fopen')
then
  create_makefile('openal');
else
  raise 'No OpenAL library found.'
end
