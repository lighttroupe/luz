class Keyboard
	def initialize(object)
		@object = object
	end

	def on_key_press(key)
		send_to_grab(key) or process_interface_key_press(key)
	end

	def grab(object=nil, &proc)
		@grab_object, @grab_proc = object, proc
	end

	def cancel_grab!
		@grab_object, @grab_proc = nil, nil
	end

	def grabbed_by_object?(object)
		@grab_object && object == @grab_object		# not true when nils
	end

private

	def send_to_grab(value)
		if @grab_proc
			@grab_proc.call(value)
			true
		elsif @grab_object
			@grab_object.on_key_press(value)
			true
		end
	end

	def process_interface_key_press(value)
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
			end
		end
	end
end
