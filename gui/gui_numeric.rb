class GuiNumeric < GuiObject
	easy_accessor :step_amount

	def initialize(object, method, min, max)
		super()
		@object, @method_get, @method_set, @min, @max = object, method, (method.to_s+'=').to_sym, min, max
		@value_label = BitmapFont.new.set(:scale_x => 0.9, :scale_y => 0.65, :offset_y => -0.12)
		@value_change_in_progress = ''
		@gui_string = GuiString.new(self, :value_change_in_progress).set(:scale_x => 0.9, :scale_y => 0.65, :offset_y => -0.12)
		@color = [0.8, 0.8, 1.0, 1.0]
	end

	attr_accessor :value_change_in_progress

	#
	# API
	#
	def get_value
		@object.send(@method_get)
	end

	def set_value(value)
		value = @min if @min && value < @min
		value = @max if @max && value > @max
		value = @zero_value if value == -@zero_value		# HACK to avoid odd case of -0.0
		@object.send(@method_set, value)
	end

	#
	# Rendering
	#
	def gui_render!
		with_gui_object_properties {
			if keyboard_focus?
				@gui_string.gui_render!
			else
				@value_label.set_string(generate_string)
				@value_label.gui_render!
			end
		}
	end

	#
	# Mouse Interaction
	#
	def scroll_up!(pointer)
		set_value(purify_value(calculate_step_value(:up)))
	end

	def scroll_down!(pointer)
		set_value(purify_value(calculate_step_value(:down)))
	end

	# double-clicking numberic fields begins keyboard edit mode
	def double_click(pointer)
		grab_keyboard_focus!
	end

	def click(pointer)
	end

	def on_key_press(key)
		case key
		when 'return'
			set_value(purify_value(@value_change_in_progress.to_f))
			@gui_string.set_value('')
			cancel_keyboard_focus!
		when 'escape'
			@gui_string.set_value('')
			cancel_keyboard_focus!
		else
			@gui_string.on_key_press(key)
		end
	end

	#
	# Helpers
	#

private

	def generate_string
		sprintf(@format_string, get_value).sub('+',' ')
	end

	def purify_value(value)
		value		# default implementation does nothing
	end
end
