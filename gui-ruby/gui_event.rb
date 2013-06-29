multi_require 'gui_list_select'

class GuiEvent < GuiListSelect
	def list
		$engine.project.events.map { |theme| GuiObjectRenderer.new(theme) }
	end

	def set_value(value)
		super(value.object)
	end
end
