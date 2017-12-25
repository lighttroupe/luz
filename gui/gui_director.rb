class GuiDirector < GuiListSelect
	def list
		$engine.project.directors.map(&:new_renderer)
	end

	def set_value(value)
		super(value ? value.object : nil)
	end
end

