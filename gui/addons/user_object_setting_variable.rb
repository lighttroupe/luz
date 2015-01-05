class UserObjectSettingVariable
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiVariable.new(self, :variable).set(:item_aspect_ratio => 5.0, :float => :left, :scale_x => 0.5)
		box << new_button=GuiButton.new.set(:scale_x => 0.08, :float => :left, :background_image => $engine.load_image('images/buttons/new-variable.png'), :background_image_hover => $engine.load_image('images/buttons/new-variable-hover.png'), :background_image_click => $engine.load_image('images/buttons/new-variable-click.png'))
		new_button.on_clicked { |pointer|
			@variable = $gui.new_variable!(pointer)
		}
		box
	end
end
