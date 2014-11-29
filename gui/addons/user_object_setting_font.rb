class UserObjectSettingFont
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << GuiSelect.new(self, :font, options).set(:scale_x => 1.0, :scale_y => 0.5, :offset_y => 0.25)
		box
	end

private

	def options
		unless @font_options
			canvas = CairoCanvas.new(0, 0)
			canvas.using { |context|
				layout = context.create_pango_layout
				pango_context = layout.context
				font_families = pango_context.font_map.families.map(&:name).sort
				@font_options = font_families.map { |name| [name, name] }
			}
		end
		@font_options
	end
end
