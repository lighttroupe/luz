#
# GuiEngineButtonRenderer wraps a single String representing a "button" value from the engine, eg "Mouse 01 / Button 01"
#
class GuiEngineButtonRenderer < GuiObject
	GUI_COLOR_ON = [0.0, 0.0, 0.4, 0.8]

	attr_reader :text

	callback :clicked

	def initialize(text)
		@text = text
	end

	def to_s
		@text
	end

	def click(pointer)
		clicked_notify(pointer)
	end

	def gui_render
		with_gui_object_properties {
			if $engine.button_down?(@text)
				with_color(GUI_COLOR_ON) {
					unit_square
				}
			end

			with_color(label_color) {
				@label ||= GuiLabel.new.set(:width => 15, :string => @text, :scale_x => 0.9, :scale_y => 0.65)
				@label.gui_render
			}
		}
	end

private

	def label_color
		[1,1,1]
	end
end
