class KeypressRouter
	def initialize(object)
		@object = object
	end

	def on_key_press(value)
		#
		# Ctrl key
		#
		if value.control?
			case value
			when 'b'
				@object.toggle_beat_monitor!
			when 'o'
				@object.output_object_counts
			when 'n'
				@object.positive_message 'TODO: add actor'
			when 'm'
				@object.positive_message 'TODO: add effect'
			when 'r'
				$engine.reload
			#when 'f11'
			#	@object.output_gc_counts
			when 'f12'
				@object.toggle_gc_timing
			end

		#
		# Alt key
		#
		elsif value.alt?
			case value
			when 'down'
				@object.select_next_actor!
			when 'up'
				@object.select_previous_actor!
			end

		#
		# no modifier
		#
		else
			case value
			when 'escape'
				@object.hide_something!
			else
				route_keypress_to_selected_widget(value)
			end
		end
	end

	def route_keypress_to_selected_widget(value)
		if @object.keyboard_grab_proc
			@object.keyboard_grab_proc.call(value)
		elsif @object.keyboard_grab_object
			@object.keyboard_grab_object.on_key_press(value)
		else
			puts "keypress-router: unhandled key '#{value}'"
		end
	end
end
