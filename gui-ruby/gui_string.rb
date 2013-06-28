require 'gui_object'

#
# GuiString is for viewing and editing a single Ruby string property of an object.
#
class GuiString < GuiObject
	FOCUS_COLOR = [1,0.9,0.3]
	FOCUS_BACKGROUND_COLOR = [0.0,0.0,0.5]
	COLOR = [1,1,1]

	def initialize(object, method)
		super()
		@object, @method = object, method
		@last_rendered_string = ''
		@label = BitmapFont.new.set(:string => get_value)
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
			if @keyboard_focus
				with_color(FOCUS_BACKGROUND_COLOR) {
					unit_square
				}
			end

			with_color(color) {
				if @keyboard_focus && $env[:beat_number] % 2 == 0
					@label.string = ((original=@label.string) + '_')
					@label.gui_render!
					@label.string = original
				else
					@label.gui_render!
				end
			}
		}
	end

	def color
		@keyboard_focus ? FOCUS_COLOR : COLOR
	end

	#
	# Mouse interaction
	#
	def click(pointer)
		@keyboard_focus = true

		# initiate keyboard grab
		$gui.grab_keyboard { |key|
			if @keyboard_focus == false
				false			# cancel grab
			elsif key == 'return' or key == 'escape'
				@keyboard_focus = false
				false			# cancel grab
			else
				if key == 'backspace'
					set_value(get_value[0, get_value.length-1])
				elsif key == 'space'
					set_value(get_value + ' ')
				elsif BitmapFont.renderable?(key)
					set_value(get_value + key)
				end
				true			# keep grab
			end
		}
	end
end
