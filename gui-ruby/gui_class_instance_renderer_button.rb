require 'gui_object_renderer_button.rb'

class GuiClassInstanceRendererButton < GuiObjectRendererButton
	def initialize(klass)
		super(klass.new)
	end
end
