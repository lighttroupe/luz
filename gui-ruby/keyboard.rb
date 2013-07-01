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
			when 'right'
				@gui.toggle_actors_flyout!
			when 'left'
				@gui.toggle_inputs_flyout!
			when 'up'
				@gui.toggle_directors_menu!
			when 'down'
				@gui.hide_something!
			when 'b'
				@gui.toggle_beat_monitor!
			when 'n'
				@gui.positive_message 'TODO: add'
			when 'r'
				$engine.reload
			when 's'
				$engine.project.save
				@gui.positive_message 'Project Saved'
			when 'f1'
				@gui.mode = :actor
			when 'f2'
				@gui.mode = :director
			when 'f3'
				@gui.mode = :output
			when 'o'
				@gui.output_object_counts
			when 'g'
				@gui.toggle_gc_timing
			#when 't'
				#ObjectSpace.each_object(Variable) { |variable| puts variable.title }
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
				if @gui.directors_menu.visible?
					@gui.close_directors_menu!
				else
					@gui.toggle!
				end
			end
		end
	end
end
