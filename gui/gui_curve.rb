class GuiCurve < GuiListSelect
	def list
		$engine.project.curves.map(&:new_renderer)
	end

	def set_value(value)
		super(value.object)
	end
end
