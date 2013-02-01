require 'gui_object'

class GuiString < GuiObject
	def initialize(object, method)
		super()
		@object, @method = object, method
		@last_rendered_string = ''
		@label = BitmapFont.new.set(:string => get_value)
	end

	def get_value
		@object.send(@method).to_s
	end

	def gui_render!
		@label.gui_render!
	end
end
