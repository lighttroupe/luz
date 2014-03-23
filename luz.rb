#!/usr/bin/env ruby
$LOAD_PATH << '/usr/lib/ruby/1.9.1/i486-linux/'

 ###############################################################################
 #  Copyright 2014 Ian McIntosh <ian@openanswers.org>
 ###############################################################################

APP_NAME = 'Luz 2.0'

Dir.chdir(File.dirname(__FILE__))	# So that this file can be run from anywhere
$LOAD_PATH.unshift('./utils').unshift('.')
$LOAD_PATH << './engine'
$LOAD_PATH << './engine/user-object-settings'

require 'reloadable_require'
multi_require 'addons_ruby', 'method_piping', 'boolean_accessor', 'constants', 'sdl', 'opengl', 'addons_gl', 'drawing', 'luz_performer'

require 'settings'
settings_path = File.join(Dir.home, SETTINGS_DIRECTORY, SETTINGS_FILENAME)
$settings = Settings.new.load(settings_path)

$application = LuzPerformer.new

require 'optparse'
options = OptionParser.new do |opts|
	opts.banner = "Usage: luz_performer.rb [options] <project.luz>"

	opts.on("--width <width>", Integer, "Resolution width (eg. 800)") do |w|
		$application.width = w
	end
	opts.on("--height <height>", Integer, "Resolution height (eg. 600)") do |h|
		$application.height = h
	end
	opts.on("--bits-per-pixel <bpp>", Integer, "Bits per pixel (8, 16, 24, 32)") do |bpp|
		$application.bits_per_pixel = bpp
	end
	opts.on("--frames-per-second <fps>", Integer, "Target FPS") do |fps|
		$application.frames_per_second = fps.to_i
	end
	opts.on("--fullscreen", "Fullscreen") do
		$application.fullscreen = true
	end
	opts.on("--window", "Window") do
		$application.fullscreen = false
	end
	opts.on("--borderless", "Borderless") do
		$application.border = false
	end
	opts.on("--relay <number>", Integer, 'Relay all received input to this local UDP port number') do |port|
		$application.relay_port = port.to_i
	end
	opts.on("--record", "Record Mode") do
		@record_video = true
	end
	opts.on("--inputs <path>", String, "Specify Inputs File (required when using --record)") do |path|
		@inputs_path = path
	end
end

# Last argument is project name
unless (project_path = ARGV.pop)
	puts options
	exit
end

options.parse!

$application.create
$engine.load_from_path(project_path)
$engine.hardwire! unless $engine.project.effects.find { |effect| effect.inhibit_hardware? }
$application.run
