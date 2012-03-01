require 'glade_window'
require 'vte'
require 'fileutils'

class RenderWindow < GladeWindow
	VIDEO_PLAY_EXECUTABLE = 'gnome-open'
	FOLDER_OPEN_EXECUTABLE = 'gnome-open'

	def initialize
		@suggested_filename = ''
		@process_queue = []

		super('render_window', :widgets => [:resolution_combobox, :project_filechooserbutton, :resolution_combobox, :music_filechooserbutton, :output_filename_error_label, :output_folder_filechooserbutton, :frames_per_second_spinbutton, :output_filename_entry, :encoding_combobox, :quality_combobox, :render_button, :terminal_container, :controls_container, :encoding_output_container, :launch_options_container])

		@resolution_combobox.active = 0		# select first option

		@terminal = Vte::Terminal.new.show
		@terminal.signal_connect('child-exited') { on_encoding_done }
		@terminal_container.add(@terminal)

		@encoding_combobox.active = 0
		@quality_combobox.active = 1

		on_key_press(Gdk::Keyval::GDK_Escape) { Gtk.main_quit }
	end

	def project=(project_filepath)
		return unless File.exist?(project_filepath)

		@project_filechooserbutton.filename = project_filepath

		# assume user will load music from the same directory and make it easier for them
		@music_filechooserbutton.current_folder = File.dirname(project_filepath) unless @music_filechooserbutton.filename
	end

	def on_values_changed
		#
		# The order of these values should match the glade file options
		#
		valid_extensions_array = ['ogv', 'mkv']		#, 'avi', 'mpg']

		#
		# Do we have all necessary settings?
		#
		input_settings_ready = (@project_filechooserbutton.filename and !@resolution_combobox.active_text.empty?)

		extension = valid_extensions_array[@encoding_combobox.active]
		quality_string = ['-HQ','','-LQ'][@quality_combobox.active].gsub(' ', '-').downcase

		#
		# Suggest an output filename
		#
		if (input_settings_ready and @output_filename_entry.text.empty?) or (!@suggested_filename.empty? and @output_filename_entry.text == @suggested_filename)
			width, height = @resolution_combobox.active_text.split(' ').first.split('x')
			fps = @frames_per_second_spinbutton.value.to_i

			@suggested_filename = sprintf("%s-%dx%d-%dfps%s.%s",
				@music_filechooserbutton.filename ? File.basename(@music_filechooserbutton.filename, '.wav') : File.basename(@project_filechooserbutton.filename, '.luz'),
				width, height, fps,
				quality_string, extension)

			@output_filename_entry.text = @suggested_filename
		end

		#
		# Ready to go?
		#
		if (input_settings_ready and !@output_filename_entry.text.empty?)
			@output_filename = @output_filename_entry.text
			@output_filepath = File.join(@output_folder_filechooserbutton.filename, @output_filename)

			#
			# Refuse to overwrite output file
			#
			if File.exist?(@output_filepath)
				@output_filename_error_label.markup = '<i>A file with that name already exists.</i>'
				@render_button.sensitive = false

			#
			# ffmpeg guesses target format by file extension, so for now that's how specify it
			#
			elsif valid_extensions_array.include?(@output_filepath.split('.').last)
				@output_filename_error_label.markup = ''
				@render_button.sensitive = true
			else
				@output_filename_error_label.markup = "<i>Name must end in #{valid_extensions_array.collect { |s| ".#{s}" }.join(', ')}</i>"
				@render_button.sensitive = false
			end
		else
			@render_button.sensitive = false
		end
	end

	def on_render_button_clicked
		project_path = @project_filechooserbutton.filename
		music_path = @music_filechooserbutton.filename
		fps = @frames_per_second_spinbutton.value.to_i
		width, height = @resolution_combobox.active_text.split(' ').first.split('x')

		quality = @quality_combobox.active		# 0(highest) to 4 (lowest)

		@controls_container.visible = false

		#
		# Recording
		#
		command = ("./luz_performer.rb --record --width #{width} --height #{height} --frames-per-second #{fps} \"#{project_path}\"")

		puts "Running: #{command}"

		system(command)

		#
		# Encoding
		#
		@encoding_output_container.visible = true

		# -y = overwrite
		# -r = fps
		# -i = input images
		# -i = input audio
		# -g = keyframe every N frames

		keyframe = '1' #(fps+1) / 2 		# 1=every frame is a keyframe, 2=every other...

		command = "ffmpeg"

		argv  = [command]		# argv[0] is the app name
		argv += ['-y']
		argv += ['-f', 'image2']
		argv += ['-r', fps.to_s]
		argv += ['-i', 'frame-%06d.bmp']
		argv += ['-i', music_path] if music_path

		case video_type
		when 'ogv'
			argv += ['-qscale', ['9', '6', '3'][quality]]		# 5 = medium, 9 = high
		when 'mkv'
			argv += ['-vcodec', 'libx264']
			argv += ['-vpre', ['libx264-hq', 'libx264-hq', 'libx264-normal', 'libx264-normal', 'libx264-fastfirstpass'][quality]]
			argv += ['-crf', ['18', '23', '28', '33', '38'][quality]]
		end

		argv += [@output_filepath]

		puts "Running: #{argv.join(' ')}"

		@terminal.feed("$ #{argv.join(' ')}\n\r")

		@terminal.fork_command(command, argv)
	end

	def video_type
		@output_filepath.split('.').last
	end

	def on_encoding_done
		@terminal.feed("\n\r")
		@terminal.feed("*************************************\n\r")
		@terminal.feed("***   Video Encoding Completed   ***\n\r")
		@terminal.feed("*************************************\n\r")

		@launch_options_container.sensitive = true
	end

	def on_play_button_clicked
		system(VIDEO_PLAY_EXECUTABLE, @output_filepath)
	end

	def on_open_folder_button_clicked
		system(FOLDER_OPEN_EXECUTABLE, @output_folder_filechooserbutton.filename)
	end

	def on_reset_button_clicked
		# Simulate a change so we recheck if the file name exists (it probably does!)
		on_values_changed

		@controls_container.visible = true
		@encoding_output_container.visible = false
		@launch_options_container.sensitive = false
	end

	def hide
		Gtk.main_quit
	end
end
