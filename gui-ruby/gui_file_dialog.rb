require 'pathname'

class GuiFileDialog < GuiBox
	attr_reader :path

	callback :selected, :closed

	DIRECTORY_COLOR = [0.5,0.5,1.0,1.0]
	FILE_COLOR = [1,1,1,1]

	def initialize
		super
		create!
	end

	def show_for_path(path, extensions=nil)
		@path = path
		@directories, @files = load_directories, load_files(extensions)
		@directory_list.clear!
		@directories.each { |filename|
			@directory_list << (renderer = GuiTextRenderer.new(filename).set(:label_color => DIRECTORY_COLOR))
			renderer.on_clicked { show_for_path(File.join(@path, filename)) }
		}
		@files.each { |filename|
			@directory_list << (renderer = GuiTextRenderer.new(filename).set(:label_color => FILE_COLOR))
			renderer.on_clicked { notify_for_filename(filename) }
		}
	end

private

	def create!
		self << GuiObject.new.set(:background_image => $engine.load_image('images/overlay.png'))		# background

		self << (@title = BitmapFont.new.set({:color => [0.6,0.6,1.0], :string => 'Open Project', :offset_x => -0.03, :offset_y => 0.47, :scale_x => 0.1, :scale_y => 0.05}))

		self << (@path_string = GuiString.new(self, :path).set(:scale_y => 0.05, :offset_y => 0.5 - 0.025))
		self << (@directory_list = GuiList.new.set(:scale_y => 0.85, :offset_x => 0.0, :offset_y => -0.03, :spacing_y => -1.0, :item_aspect_ratio => 16.5))

		self << (@up_button=GuiButton.new.set(:scale_x => 0.15, :scale_y => -0.07, :offset_x => -0.40, :offset_y => 0.5 - 0.035, :background_image => $engine.load_image('images/buttons/close.png')))
		@up_button.on_clicked { show_for_path(File.join(@path, '..')) }

		self << (@close_button=GuiButton.new.set(:scale_x => 0.3, :scale_y => 0.05, :offset_x => 0.0, :offset_y => -0.5 + 0.025, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked { closed_notify }
	end

	def load_directories
		directories = []
		Dir.new(@path).each { |filename|
			directories << filename if File.directory?(File.join(@path, filename))
		}
		directories.delete('.')
		directories.delete('..')
		directories.sort
	end

	def load_files(extensions)
		files = []
		Dir.new(@path).each_with_extensions(extensions) { |filename|
			files << File.basename(filename) unless File.directory?(filename)
		}
		files
	end

	def notify_for_filename(filename)
		selected_notify(Pathname.new(File.join(@path, filename)).realpath.to_s)
	end
end
