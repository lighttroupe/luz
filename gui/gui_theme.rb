class GuiTheme < GuiListSelect
	def list
		$engine.project.themes.map(&:new_renderer)
	end

	def set_value(value)
		super(value.object) if value
	end
end
