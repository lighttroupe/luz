require 'gui_list_select'

class GuiActor < GuiListSelect
	def list
		#actors = [] ; ObjectSpace.each_object(Actor) { |a| actors << a }
		$engine.project.actors.map { |actor| GuiObjectRenderer.new(actor) }
	end

	def set_value(value)
		super(value.object)
	end
end
