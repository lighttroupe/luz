class UserObjectSettingSlider
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << slider_widget=GuiEngineSlider.new(self, :slider).set(:scale_x => 0.5, :float => :left, :scale_y => 0.5, :offset_y => 0.0, :item_aspect_ratio => 6.0)
		box << record_button=GuiButton.new.set(:scale_x => 0.05, :float => :left, :background_image => $engine.load_image('images/buttons/menu.png'), :background_image_hover => $engine.load_image('images/buttons/menu.png'), :background_image_click => $engine.load_image('images/buttons/menu.png'))
		record_button.on_clicked {
			$engine.slider_grab { |slider|
				slider_widget.set_value(slider) unless slider.include?('Mouse')			# HACK: rather impossible to capture anything when spamming inputs like mice		TODO: tablets, wiimotes...
			}
		}
		box << GuiCurveIncreasing.new(self, :output_curve).set(:float => :left, :scale_x => 0.2)
		box
	end
end
