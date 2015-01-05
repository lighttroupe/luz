class UserObjectSettingImage
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << @image_name_string = GuiString.new(self, :image_name).set(:width => 25, :float => :left, :scale_x => 0.8, :scale_y => 0.4, :offset_y => 0.0)

		box << @open_button = GuiButton.new.set(:scale_x => 0.1, :scale_y => 0.6, :float => :left, :offset_y => 0.0, :background_image => $engine.load_image('images/buttons/open.png'), :background_image_hover => $engine.load_image('images/buttons/open-hover.png'))
		@open_button.on_clicked {
			$gui.choose_image { |path|
				# convert absolute path to relative (TODO: must be a better way)
				relative_path = Pathname.new(File.new(path)).relative_path_from(Pathname.new(File.dirname(File.expand_path($engine.project.path))))
				self.image_name = relative_path.to_s
				@image_name_string.set_value(relative_path.to_s)
			}
		}
		box << @clear_button = GuiButton.new.set(:scale_x => 0.09, :scale_y => 0.6, :float => :left,  :offset_x => 0.01, :offset_y => -0.03, :background_image => $engine.load_image('images/buttons/clear.png'), :background_image_hover => $engine.load_image('images/buttons/clear-hover.png'))
		@clear_button.on_clicked {
			self.image_name = ''
			@image_name_string.set_value('')
		}
		box
	end
end

