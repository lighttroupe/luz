multi_require 'gui_list_select'

class GuiVariable < GuiListSelect
	def initialize(object, method)		# options is [[:one,'One'],[:two,'Two']]
		super(object, method)
		@item_aspect_ratio = 4.0
	end

	def list
		$engine.project.variables.map { |theme| GuiObjectRenderer.new(theme) }
	end

	def set_value(value)
		super(value.object)
	end
end
