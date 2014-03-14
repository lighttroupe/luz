#
# GuiEngineSliderText wraps a single String representing a "slider" value from the engine, eg "Mouse 01 / X"
#
class GuiEngineSliderRenderer < GuiObject
	VALUE_COLOR = [0.0, 0.0, 0.4, 0.8]

	attr_reader :text

	callback :clicked

	def initialize(text)
		@text = text
	end

	def click(pointer)
		clicked_notify(pointer)
	end

	def gui_render!
		with_gui_object_properties {
			render_bar($engine.slider_value(@text))

			with_color(label_color) {
				@label ||= BitmapFont.new.set(:string => @text, :scale_x => 0.9, :scale_y => 0.65)
				@label.gui_render!
			}
		}
	end

private

	def render_bar(value)
		if value > 0.0
			with_translation(-0.5 + value/2.0, 0.0) {
				with_scale_unsafe(value, 1.0) {
					with_color_listsafe(VALUE_COLOR) {
						unit_square
					}
				}
			}
		end
	end

	def label_color
		[1,1,1]
	end
end
