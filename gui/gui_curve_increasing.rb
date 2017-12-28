class GuiCurveIncreasing < GuiListSelect
	def list
		$engine.project.curves.select(&:up?).map(&:new_renderer)
	end

	def set_value(value)
		super(value.object)
	end
end
