require 'gui_file_object'

class GuiImageDialog < GuiFileDialog
	def create!
		super
		@directory_list.set(:scale_x => 0.35, :scale_y => 0.75, :offset_x => -0.5 + 0.36 / 2.0, :offset_y => -0.04, :item_aspect_ratio => 6.5)
		self << @images_grid = GuiGrid.new.set(:min_columns => 4, :scale_x => 0.6, :scale_y => 0.5, :offset_x => 0.19, :offset_y => 0.1, :spacing_x => 0.2, :spacing_y => 0.1, :item_scale_x => 0.9, :item_scale_y => 0.8)
	end

	def add_files
		@images_grid.clear!
		Dir.new(@path).each_with_extensions(Engine::SUPPORTED_IMAGE_EXTENSIONS) { |filename|
			@images_grid << GuiFileObject.new(self, filename) unless File.directory?(filename)
		}
	end
end
