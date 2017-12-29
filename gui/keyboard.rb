class Keyboard
	SHIFT_KEYS = ['left shift', 'right shift']
	boolean_accessor :shift_down

	def initialize(gui)
		@gui = gui
	end

	def raw_key_up(key)
		@shift_down = false if SHIFT_KEYS.include?(key)
	end

	def raw_key_down(key)
		@shift_down = true if SHIFT_KEYS.include?(key)

		if @grab_proc
			#$gui.positive_message "proc"
			@grab_proc.call(key)
		elsif @grab_object && !@grab_object.hidden?		# NOTE object can hide and unhide
			#$gui.positive_message "o:#{@grab_object}"
			@grab_object.on_key_press(key)
		else
			@gui.on_key_press(key)
		end
	end

	def grab(object=nil, &proc)
		@grab_object, @grab_proc = object, proc
	end

	def cancel_grab!
		cancel_grab_silently!
		@gui.default_focus!		# alert the world!
	end

	def cancel_grab_silently!
		@grab_object, @grab_proc = nil, nil
	end

	def grabbed_by_object?(object)
		!@grab_object.nil? && object == @grab_object		# not true when nils
	end
end
