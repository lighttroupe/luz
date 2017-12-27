class GuiNumeric < GuiValue
	easy_accessor :step_amount

	pipe [:text_align=, :width=], :value_label

	EDIT_MODE_COLOR = [1.0,1.0,0.0]

	def initialize(object, method, min, max)
		super(object, method)
		@min, @max = min, max
		@value_label = GuiLabel.new.set(:width => 4, :text_align => :right)		#.set(:scale_x => 0.9, :scale_y => 0.65, :offset_y => -0.12)
		@value_change_in_progress = ''
		@gui_string = GuiString.new(self, :value_change_in_progress).set(:color => EDIT_MODE_COLOR, :width => 4, :text_align => :center)
		@color = [0.8, 0.8, 1.0, 1.0]
	end

	attr_accessor :value_change_in_progress

	#
	# API
	#
	def set_value(value)
		super(clamp_value(value))
	end

	def clamp_value(value)
		value = @min if @min && value < @min
		value = @max if @max && value > @max
		value = @zero_value if value == -@zero_value		# HACK to avoid odd case of -0.0
		value
	end

	# TODO: rename get_value, set_value to value, value=
	def value ; get_value ; end
	def value=(v) ; set_value(v) ; end

	#
	# Rendering
	#
	def gui_render
		with_gui_object_properties {
			if keyboard_focus? && @value_change_in_progress.length > 0
				# faint display of current value
				with_alpha(0.1) {
					@value_label.set_string(generate_string)		# TODO: avoid this work
					@value_label.gui_render
				}
				# new value in progress
				@gui_string.gui_render

				# outline for edit mode
				with_color(EDIT_MODE_COLOR) { unit_square_outline }
			else
				@value_label.set_string(generate_string)		# TODO: avoid this work

				if keyboard_focus?
					with_color(EDIT_MODE_COLOR) { @value_label.gui_render }
				else
					@value_label.gui_render
				end
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

	def double_click(pointer)
	end

	def click(pointer)
		grab_keyboard_focus!
	end

	NUMERIC_CHARACTERS = ['0','1','2','3','4','5','6','7','8','9','-','.']

	def on_key_press(key)
		return super if key.control?
		case key
		when 'space'
			# ignore
		when 'escape'
			@gui_string.set_value('')
			cancel_keyboard_focus!
		when 'backspace'
			@gui_string.on_key_press(key)
		when 'up'
			scroll_up!(pointer=nil)
		when 'down'
			scroll_down!(pointer=nil)
		when 'return'
			cancel_keyboard_focus!

			# finalize manual value change
			# feature: hold shift to animate the value to the new setting
			value = current_user_input
			return unless value
			if key.shift?
				add_animation(:value, value, duration=$settings['value-animation-time'].to_f)
			else
				cancel_animations_for_field!(:value)
				set_value(value)
			end
			@gui_string.set_value('')

			#grab_keyboard_focus!
		else
			@gui_string.on_key_press(key) if NUMERIC_CHARACTERS.include?(key)
		end
	end

	def current_user_input
		return nil unless @value_change_in_progress.strip.length > 0
		clamp_value(purify_value(@value_change_in_progress.to_f))
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
