multi_require 'gui_list_select'

class GuiCurve < GuiListSelect
	def list
		$engine.project.curves.map { |theme| GuiObjectRenderer.new(theme) }
	end

	def set_value(value)
		super(value.object)
	end
end
