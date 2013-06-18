#
# GuiEngineButtonRenderer wraps a single String representing a "button" value from the engine, eg "Mouse 01 / Button 01"
#
class GuiEngineButtonRenderer < GuiObject
	GUI_COLOR_ON = [0.0, 0.0, 0.4, 0.8]
	GUI_COLOR_OFF = [0.0,0.0,0.0,1.0]

	attr_reader :text

	def initialize(text)
		@text = text
	end

	def gui_render!
		if $engine.button_down?(@text)
			with_color(GUI_COLOR_ON) {
				unit_square
			}
		end

		with_color(label_color) {
			@label ||= BitmapFont.new.set(:string => @text, :scale_x => 0.9, :scale_y => 0.65)
			@label.gui_render!
		}
	end

private

	def label_color
		[1,1,1]
	end
end
