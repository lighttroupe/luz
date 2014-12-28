class UserObjectSettingButton
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << button_widget=GuiEngineButton.new(self, :button).set(:scale_x => 0.5, :scale_y => 0.5, :float => :left)
		box << record_button=GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.5, :float => :left, :background_image => $engine.load_image('images/buttons/record.png'), :background_image_hover => $engine.load_image('images/buttons/record-hover.png'), :background_image_click => $engine.load_image('images/buttons/record-click.png'))
		record_button.on_clicked {
			$engine.button_grab { |button|
				button_widget.set_value(button)
			}
		}
		box
	end
end
