class UserObjectSettingTheme
	def gui_build_editor
		box = GuiBox.new
		box << GuiTheme.new(self, :theme).set(:scale_x => 0.25, :scale_y => 0.75, :float => :left, :offset_x => 0.02, :offset_y => -0.08)
		box << create_user_object_setting_name_label
		box << new_button=GuiButton.new.set(:scale_x => 0.08, :float => :left, :background_image => $engine.load_image('images/buttons/new-event.png'), :background_image_hover => $engine.load_image('images/buttons/new-event-hover.png'), :background_image_click => $engine.load_image('images/buttons/new-event-click.png'))
		new_button.on_clicked { |pointer|
			@theme = $gui.new_theme!(pointer)
		}
		box << edit_button=GuiButton.new.set(:float => :left, :scale_x => 0.07, :background_image => $engine.load_image('images/buttons/edit-actor.png'), :background_image_hover => $engine.load_image('images/buttons/edit-actor-hover.png'), :background_image_click => $engine.load_image('images/buttons/edit-actor-click.png'))
		edit_button.on_clicked { |pointer|
			$gui.build_editor_for(@theme, :pointer => pointer)
		}
		box << clear_button=GuiButton.new.set(:float => :left, :scale_x => 0.07, :background_image => $engine.load_image('images/buttons/clear.png'), :background_image_hover => $engine.load_image('images/buttons/clear-hover.png'), :background_image_click => $engine.load_image('images/buttons/clear-click.png'))
		clear_button.on_clicked {
			@theme = nil
		}
		box
	end
end
