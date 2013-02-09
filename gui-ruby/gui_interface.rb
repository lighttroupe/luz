class GuiInterface < GuiBox
	# Called by SDL
	def raw_keyboard_input(value)
		route_keypress(value)
	end

	def grab_keyboard(&proc)
		@keyboard_grab_proc = proc
	end

	def route_keypress(value)
		if @keyboard_grab_proc
			@keyboard_grab_proc = nil if @keyboard_grab_proc.call(value) == false
		else
			on_key_press(value)
		end
	end
end
