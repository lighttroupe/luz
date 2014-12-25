require 'gui_list_select'

class GuiDirector < GuiListSelect
	def list
		#actors = [] ; ObjectSpace.each_object(Actor) { |a| actors << a }
		$engine.project.directors.map { |director| GuiObjectRenderer.new(director) }
	end

	def set_value(value)
		value ? super(value.object) : super(nil)
	end
end

