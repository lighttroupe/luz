class GuiEvent < GuiListSelect
	def list
		$engine.project.events.map(&:new_renderer)
	end

	def set_value(value)
		super(value.object)
	end
end
