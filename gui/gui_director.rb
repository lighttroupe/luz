#
# GuiDirector is a widget for selecting a Director instance variable
#
class GuiDirector < GuiListSelect
	def initialize(object, method)
		super
		@item_aspect_ratio = 1.3
	end

	def list
		$engine.project.directors.map(&:new_renderer)
	end

	def set_value(value)
		super(value ? value.object : nil)
	end
end
