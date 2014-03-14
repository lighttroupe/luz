class Keyboard
	def initialize(gui)
		@gui = gui
	end

	def raw_keyboard_input(key)
		# TODO: filter somehow?
		send_key_to_grab(key) or @gui.on_key_press(key)
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

private

	def send_key_to_grab(key)
		if @grab_proc
			@grab_proc.call(key)
			true
		elsif @grab_object && !@grab_object.hidden?		# NOTE object can hide and unhide 
			@grab_object.on_key_press(key)
			true
		else
			false
		end
	end
end
