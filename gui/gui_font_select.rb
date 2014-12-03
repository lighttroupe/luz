class GuiFontSelect < GuiListSelect
	def list
		$gui_font_select_options ||= build_available_font_family_list
		$gui_font_select_options.map { |name| GuiTextRenderer.new(name) }
	end

	def build_available_font_family_list
		canvas = CairoCanvas.new(0, 0)
		canvas.using { |context|
			layout = context.create_pango_layout
			pango_context = layout.context
			return pango_context.font_map.families.map(&:name).sort
		}
		[]
	end

	def set_value(value)
		super(value.text)
	end

	#
	# Render
	#
	def gui_render!
		font_name = get_value
		return super unless font_name		# "none" text
		with_gui_object_properties {
			@value_label ||= GuiLabel.new.set(:width => 15, :scale => 0.75)
			@value_label.set_string(font_name)
			@value_label.gui_render!
		}
	end
end
