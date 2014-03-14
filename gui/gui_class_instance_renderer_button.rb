require 'gui_object_renderer_button.rb'

class GuiClassInstanceRendererButton < GuiObjectRendererButton
	attr_reader :klass

	def initialize(klass)
		@klass = klass
		super(klass.new)
	end
end
