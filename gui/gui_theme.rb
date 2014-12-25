class GuiTheme < GuiListSelect
	def list
		$engine.project.themes.map { |theme| GuiObjectRenderer.new(theme) }
	end

	def set_value(value)
		super(value.object) if value
	end
end
