class GuiVariable < GuiListSelect
	def initialize(object, method)
		super(object, method)
		@item_aspect_ratio = 4.0
	end

	def list
		$engine.project.variables.map(&:new_renderer)
	end

	def set_value(value)
		super(value.object) if value
	end
end
