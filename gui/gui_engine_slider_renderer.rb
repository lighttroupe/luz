#
# GuiEngineSliderText wraps a single String representing a "slider" value from the engine, eg "Mouse 01 / X"
#
class GuiEngineSliderRenderer < GuiLabel
	VALUE_COLOR = [0.0, 0.0, 0.4, 0.8]

	def initialize(slider_name)
		@string = slider_name		# @string is what GuiLabel wants
		set(:width => 15)
	end

	def to_s
		@string
	end

	def ==(s)
		@string == s
	end

	def gui_render
		with_gui_object_properties {
			with_color_listsafe(VALUE_COLOR) {
				render_progress_bar_with_cache($engine.slider_value(@string))
			}
			super			# normal label
		}
	end
end
