require 'gui_object'

class GuiString < GuiObject
	FOCUS_COLOR = [1,1,0.2]
	FOCUS_BACKGROUND_COLOR = [0.1,0.1,0.1]
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
		if @keyboard_focus
			with_color(FOCUS_BACKGROUND_COLOR) {
				unit_square_outline
			}
		end

		with_color(color) {
			@label.gui_render!
			if @keyboard_focus
			end
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
			next unless @keyboard_focus

			if key == 'return' or key == 'escape'
				@keyboard_focus = false
				false			# cancel grab
			elsif 
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
