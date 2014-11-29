#
# GuiTextRenderer is intended to render a string in a list
#
class GuiTextRenderer < GuiObject
	attr_reader :text

	easy_accessor :label_color

	callback :clicked

	def initialize(text)
		@text = text
	end

	def click(pointer)
		clicked_notify(pointer)
	end

	DEFAULT_COLOR = [1,1,1,1]

	def gui_render!
#		with_gui_object_properties {
			with_color(label_color || DEFAULT_COLOR) {
				@label ||= BitmapFont.new.set(:string => @text, :scale_x => 0.9, :scale_y => 0.65)
				@label.gui_render!
			}
#		}
	end
end
