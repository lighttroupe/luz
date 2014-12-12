class GuiFontSelect < GuiListSelect
	def initialize(*args)
		@value_label = GuiLabel.new.set(:width => 15)
		super
	end

	pipe :width=, :value_label

	def list
		$gui_font_select_options ||= build_available_font_family_list
		$gui_font_select_options.map { |name| GuiLabel.new.set(:string => name, :width => 15) }
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
		super(value.string)
	end

	#
	# Render
	#
	def gui_render!
		font_name = get_value
		return super unless font_name		# "none" text
		with_gui_object_properties {
			@value_label.set_string(font_name)
			@value_label.gui_render!
		}
	end
end
