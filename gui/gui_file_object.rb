#
# GuiFileObject represents a file in the file system and shows a thumbnail, if present
#
class GuiFileObject < GuiObject
	def initialize(dialog, path)
		@dialog, @path = dialog, path
		$engine.load_image_thumbnail(path) { |thumbnail|
			set(:background_image => thumbnail)
		}
	end

	def click(pointer)
		@dialog.selected_notify(@path)
	end
end
