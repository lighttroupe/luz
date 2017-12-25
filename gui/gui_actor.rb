class GuiActor < GuiListSelect
	def list
		$engine.project.actors.map(&:new_renderer)
	end

	def set_value(value)
		super(value ? value.object : nil)
	end
end
