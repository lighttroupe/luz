class UserObjectSettingSlider
	attr_accessor :input_min, :input_max, :output_min, :output_max

	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << slider_widget=GuiEngineSlider.new(self, :slider).set(:scale_x => 0.5, :float => :left, :scale_y => 0.5, :offset_y => 0.0, :item_aspect_ratio => 6.0)
		box << record_button=GuiButton.new.set(:scale_x => 0.05, :scale_y => 0.7, :float => :left, :background_image => $engine.load_image('images/buttons/record.png'), :background_image_hover => $engine.load_image('images/buttons/record-hover.png'), :background_image_click => $engine.load_image('images/buttons/record-click.png'))
		record_button.on_clicked {
			$engine.slider_grab { |slider|
				slider_widget.set_value(slider) unless slider.include?('Mouse')			# HACK: rather impossible to capture anything when spamming inputs like mice		TODO: tablets, wiimotes...
			}
		}

		box << (input_min=GuiFloat.new(self, :input_min, 0.0, 1.0).set(:scale_x => 0.07, :scale_y => 0.6, :offset_y => 0.0, :float => :left))
		box << (input_max=GuiFloat.new(self, :input_max, 0.0, 1.0).set(:scale_x => 0.07, :scale_y => 0.6, :offset_y => 0.0, :float => :left))
		box << GuiLabel.new.set(:string => 'input', :width => :fill, :color => [0.8,0.8,1.0], :offset_x => 0.13, :scale_x => 0.07, :offset_y => -0.35, :scale_y => 0.3)

		box << GuiCurveIncreasing.new(self, :output_curve).set(:float => :left, :scale_x => 0.12, :scale_y => 0.5)

		box << (output_min=GuiFloat.new(self, :output_min, 0.0, 1.0).set(:scale_x => 0.07, :scale_y => 0.6, :offset_y => 0.0, :float => :left))
		box << (output_max=GuiFloat.new(self, :output_max, 0.0, 1.0).set(:scale_x => 0.07, :scale_y => 0.6, :offset_y => 0.0, :float => :left))
		box << GuiLabel.new.set(:string => 'output', :width => :fill, :color => [0.8,0.8,1.0], :offset_x => 0.39, :scale_x => 0.07, :offset_y => -0.35, :scale_y => 0.3)

		box
	end
end
