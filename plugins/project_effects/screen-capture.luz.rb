 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

class ProjectEffectScreenCapture < ProjectEffect
	title				"Screen Capture"
	description "Saves a PNG file of the current frame."

	hint "The location of saved files defaults to your project's directory, but can be changed in Luz Studio's settings."

	setting 'event', :event

	RAW_IMAGE_ENCODER_NAME = 'convert'

	def tick
		if (event.now? and $gui.nil?)	# NOTE: only operates in performer
			time = Time.now
			output_filename = sprintf("luz-screenshot-%04d_%02d_%02d-%02d_%02d_%02d_%04d-%06d.png", time.year, time.month, time.day, time.hour, time.min, time.sec, time.usec/100, $env[:frame_number]) # time for good file system sorting, frame number to further promote uniqueness
			output_filepath = File.join($engine.project.file_path, output_filename)

			# Get pixels and write them to temporary file
			capture_start_time = Time.now
			return if (pixels = $application.get_framebuffer_rgb).nil?		# not necessarily supported (eg. in editor)
			puts "framebuffer capture took #{Time.now-capture_start_time} seconds"

			# Check for presence of raw->png converter app NOTE: only does this once
			@raw_image_encoder_present = !(open("|which #{RAW_IMAGE_ENCODER_NAME}").read.empty?) if @raw_image_encoder_present.nil?

			if @raw_image_encoder_present
				raw_filepath = output_filepath.sub(/\.png$/, '.raw')
				File.open(raw_filepath, 'w') { |f| f.write(pixels) }

				# Run 'convert' in another process
				# Use 'nice' at maximum niceness to help prevent disruption - TODO: run all conversions at shutdown time?
				cmd = "nice -n 19 convert -flip -depth 8 -size #{$application.width}x#{$application.height} rgb:\"#{raw_filepath}\" \"#{output_filepath}\" ; rm \"#{raw_filepath}\""
				puts "executing: #{cmd}"
				open("|#{cmd}")
			else
				puts "compressing screen capture in-process (HINT: install the ImageMagick 'convert' application for faster screenshots)" unless @warned
				@warned = true

				image = Magick::Image.new($application.width, $application.height)
				image.import_pixels(0, 0, $application.width, $application.height, "RGB", pixels, Magick::CharPixel)
				image.flip!			# data comes at us upside down
				image.write(output_filepath)
			end
		end
	end
end
