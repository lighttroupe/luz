#
# GuiString is for viewing and editing a single Ruby string property of an object.
#
class GuiString < GuiValue
	FOCUS_COLOR = [1,1,0.3]
	FOCUS_BACKGROUND_COLOR = [0.15,0.15,0.05]

	HOVER_BACKGROUND_COLOR = [0.1,0.1,0.1]
	COLOR = [1,1,1]

	pipe [:width, :width=, :text_align, :text_align=], :label

	easy_accessor :color, :focus_color

	def initialize(object, method)
		super
		@last_rendered_string = ''
		@label = GuiLabel.new.set(:string => get_value)
	end

	def get_value
		super.to_s
	end

	def set_value(value)
		super
		@label.string = value
	end

	def gui_render
		with_positioning {
			if keyboard_focus?
				modulate = fuzzy_sine($env[:beat]).scale(0.5, 1.0)
				with_color([FOCUS_BACKGROUND_COLOR[0] * modulate, FOCUS_BACKGROUND_COLOR[1] * modulate, FOCUS_BACKGROUND_COLOR[2] * modulate]) { unit_square }
				with_alpha(fuzzy_sine($env[:beat]).scale(0.8, 1.0)) {
					@label.gui_render
				}
				with_color([0.2,0.2,0.0]) { unit_square_outline }

			elsif pointer_hovering?
				with_color(HOVER_BACKGROUND_COLOR) { unit_square }
				@label.gui_render
			else
				@label.gui_render
			end
		}
	end

	def renderable?(key)
		CairoFont.renderable?(key)
	end

	#
	# Mouse interaction
	#
	def click(pointer)
		grab_keyboard_focus!
	end

	def on_key_press(key)
		case key
		when 'return', 'escape', 'tab'
			cancel_keyboard_focus!
		when 'backspace'
			if key.alt?
				set_value('')																# alt-backspace erases string
			elsif key.control?
				if (last_space=get_value.rindex(' '))
					set_value(get_value[0, last_space])				# control-backspace removes a word
				else
					set_value('')		# (only one word left)
				end
			else
				set_value(get_value[0, get_value.length-1]) if get_value.length > 0				# basic backspace
			end
		when 'space'
			append_text(' ')
		else
			# (player typing)
			append_text(key.shifted) if renderable?(key)		# shifted means with shift key logic applied (eg. / => ?)
		end
	end

	def append_text(text)
		set_value(get_value + text)
	end
end
