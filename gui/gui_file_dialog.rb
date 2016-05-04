require 'pathname'

#
# GuiFileDialog is a file browser/chooser
#
class GuiFileDialog < GuiWindow
	attr_accessor :path

	callback :selected, :closed

	DIRECTORY_COLOR = [0.5,0.5,1.0,1.0]
	FILE_COLOR = [0.7, 0.96, 0.7]

	def initialize(title, extensions=nil)
		super()
		@title = title
		@extensions = extensions
		create!
	end

	def show_for_path(path)
		return unless File.exists?(path)
		path = Pathname.new(path).realpath.to_s
		self.path = path
		@path_label.string = path
	end

	def path=(path)
		@directory_list.clear!
		if File.exists?(path)
			@path = Pathname.new(path).realpath.to_s
			@directories, @files = load_directories, load_files
			fill_directory_list
		end
	end

	def fill_directory_list
		add_directories
		add_files
	end

	def add_directories
		@directories.each { |filename|
			@directory_list << (renderer = GuiLabel.new.set(:string => filename, :width => 25, :color => DIRECTORY_COLOR))
			renderer.on_clicked { show_for_path(File.join(@path, filename)) }
		}
	end

	def add_files
		@files.each { |filename|
			@directory_list << (renderer = GuiLabel.new.set(:string => filename, :width => 25, :color => FILE_COLOR))
			renderer.on_clicked { notify_for_filename(filename) }
		}
	end

	def notify_for_filename(filename)
		selected_notify(Pathname.new(File.join(@path, filename)).realpath.to_s)
	end

private

	def create!
		self << (@overlay = GuiObject.new.set(:background_image => $engine.load_image('images/file-dialog-background.png')))

		self << (@background = GuiObject.new.set(:scale_x => 0.3, :color => [0,0,0]))

		self << (@title_label = GuiLabel.new.set({:width => 20, :text_align => :center, :color => [0.6,0.6,1.0], :string => @title, :offset_x => 0.0, :offset_y => 0.47, :scale_x => 0.3, :scale_y => 0.05}))

		self << (@up_button=GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.07, :offset_x => -0.17, :offset_y => 0.5 - 0.23, :background_image => $engine.load_image('images/buttons/directory-up.png'), :background_image_hover => $engine.load_image('images/buttons/directory-up-hover.png')))
		@up_button.on_clicked { show_for_path(File.join(@path, '..')) }

		self << (@path_label = GuiLabel.new.set(:width => 40, :text_align => :center, :color => [1.0,1.0,1.0], :scale_x => 0.7, :scale_y => 0.04, :offset_y => 0.5 - 0.08))

		self << (@open_button = GuiLabel.new.set({:width => 10, :color => [0.2,0.8,0.2], :string => 'choose this one', :offset_x => 0.01, :offset_y => 0.5 - 0.13, :scale_x => 0.15, :scale_y => 0.05}))

		self << (@directory_list = GuiList.new.set(:scale_x => 0.25, :scale_y => 0.825, :offset_x => 0.0, :offset_y => -0.1, :spacing_y => -1.0, :item_aspect_ratio => 8.0))

		self << (@close_button=GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.06, :offset_x => 0.475, :offset_y => 0.47, :background_image => $engine.load_image('images/buttons/file-dialog-cancel.png'), :background_image_hover => $engine.load_image('images/buttons/file-dialog-cancel-hover.png'), :background_image_click => $engine.load_image('images/buttons/file-dialog-cancel-click.png')))
		@close_button.on_clicked { closed_notify }

		# focus
		#@directory_list.grab_keyboard_focus!
	end

	def load_directories
		directories = []
		Dir.new(@path).each { |filename|
			directories << filename if show_directory?(filename)
		}
		directories.delete('.')
		directories.delete('..')
		directories.sort
	end

	def show_directory?(filename)
		return false if filename[0] == '.'
		File.directory?(File.join(@path, filename))		# it exists.
	end

	def load_files
		files = []
		Dir.new(@path).each_with_extensions(@extensions) { |filepath|
			files << File.basename(filepath) if show_path?(filepath)
		}
		files
	end

	def show_path?(filepath)
		File.exist?(filepath) && !File.directory?(filepath)
	end
end
