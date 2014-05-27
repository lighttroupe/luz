class UserObjectSettingEvent
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiEvent.new(self, :event).set(:item_aspect_ratio => 5.0, :float => :left, :scale_x => 0.5)
		box << new_button=GuiButton.new.set(:scale_x => 0.08, :float => :left, :background_image => $engine.load_image('images/buttons/new.png'), :background_image_hover => $engine.load_image('images/buttons/new.png'), :background_image_click => $engine.load_image('images/buttons/new.png'))
		new_button.on_clicked { |pointer|
			@event = $gui.new_event!(pointer)
		}
		box
	end
end
