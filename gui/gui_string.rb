require 'gui_object'

#
# GuiString is for viewing and editing a single Ruby string property of an object.
#
class GuiString < GuiObject
	FOCUS_COLOR = [1,1,0.3]
	FOCUS_BACKGROUND_COLOR = [0.2,0.2,0.5]
	COLOR = [1,1,1]

	def initialize(object, method)
		super()
		@object, @method = object, method
		@last_rendered_string = ''
		@label = GuiLabel.new.set(:string => get_value)
	end

	def get_value
		@object.send(@method).to_s
	end

	def set_value(value)
		@object.send(@method.to_s+'=', value)
		@label.string = value
	end

	def gui_render!
		with_positioning {
			if keyboard_focus?
				with_color(FOCUS_BACKGROUND_COLOR) {
					unit_square
				}
			end

			with_color(color) {
				# TODO @label.keyboard_focus = keyboard_focus?
				@label.gui_render!
			}
		}
	end

	def color
		keyboard_focus? ? FOCUS_COLOR : COLOR
	end

	def renderable?(key)
		BitmapFont.renderable?(key)
	end

	#
	# Mouse interaction
	#
	def click(pointer)
		grab_keyboard_focus!
	end

	def on_key_press(key)
		case key
		when 'return', 'escape'
			cancel_keyboard_focus!
		when 'backspace'
			if key.alt?
				set_value('')
			else
				set_value(get_value[0, get_value.length-1]) if get_value.length > 0
			end
		when 'space'
			append_text(' ')
		else
			if renderable?(key)
				append_text(key.shift? ? key.upcase : key)
			end
		end
	end

	def append_text(text)
		set_value(get_value + text)
	end
end
