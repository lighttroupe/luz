multi_require 'gui_list_select'

class GuiTheme < GuiListSelect
	def list
		$engine.project.themes.map { |theme| GuiObjectRenderer.new(theme) }
	end

	def set_value(value)
		super(value.object)
	end
end
