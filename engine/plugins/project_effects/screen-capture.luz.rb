class ProjectEffectScreenCapture < ProjectEffect
	title				"Screen Capture"
	description "Saves a PNG file of the current frame."

	hint "The location of saved files defaults to your project's directory, but can be changed in Luz Studio's settings."

	setting 'event', :event

	RAW_IMAGE_ENCODER_NAME = 'convert'

	def get_framebuffer_rgb8
		capture_start_time = Time.now
		pixels = $application.get_framebuffer_rgb
		puts "framebuffer capture took #{Time.now-capture_start_time} seconds"
		pixels
	end

	def generate_output_filepath
		time = Time.now
		output_filename = sprintf("luz-screenshot-%04d_%02d_%02d-%02d_%02d_%02d_%04d-%06d.png", time.year, time.month, time.day, time.hour, time.min, time.sec, time.usec/100, $env[:frame_number]) # time for good file system sorting, frame number to further promote uniqueness
		if (p=$engine.project.file_path)
			File.join(p, output_filename)
		elsif (p=desktop_directory)
			File.join(p, output_filename)
		else
			File.join(Dir.home, output_filename)
		end
	end

	def desktop_directory
		p = File.join(Dir.home, "Desktop")
		p if File.exists?(p)
	end

	def save_pixels_to_path(pixels, output_filepath)
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

	def tick
		if event.now?
			output_filepath = generate_output_filepath

			# Get pixels and write them to temporary file
			return if (pixels = get_framebuffer_rgb8).nil?

			save_pixels_to_path(pixels, output_filepath)
		end
	end
end
