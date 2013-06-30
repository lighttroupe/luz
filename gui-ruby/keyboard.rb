class Keyboard
	def initialize(gui)
		@gui = gui
	end

	def on_key_press(key)
		send_key_to_grab(key) or process_interface_key_press(key)
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

	def send_key_to_grab(key)
		if @grab_proc
			@grab_proc.call(key)
			true
		elsif @grab_object
			@grab_object.on_key_press(key)
			true
		end
	end

	def process_interface_key_press(key)
		#
		# Ctrl key
		#
		if key.control?
			case key
			when 'b'
				@gui.toggle_beat_monitor!
			when 'o'
				@gui.output_object_counts
			when 'n'
				@gui.positive_message 'TODO: add actor'
			when 'm'
				@gui.positive_message 'TODO: add effect'
			when 'r'
				$engine.reload
			#when 'f11'
			#	@gui.output_gc_counts
			when 'f12'
				@gui.toggle_gc_timing
			end

		#
		# Alt key
		#
		elsif key.alt?
			case key
			when 'down'
				@gui.select_next_actor!
			when 'up'
				@gui.select_previous_actor!
			end

		#
		# no modifier
		#
		else
			case key
			when 'escape'
				@gui.toggle!
			end
		end
	end
end
