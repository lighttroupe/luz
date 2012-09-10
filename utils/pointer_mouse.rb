class PointerMouse < Pointer
	X,Y,BUTTON_01,WHEEL_UP,WHEEL_DOWN,WHEEL_LEFT,WHEEL_RIGHT = 'Mouse 01 / X', 'Mouse 01 / Y', 'Mouse 01 / Button 01', 'Mouse 01 / Button 04', 'Mouse 01 / Button 05', 'Mouse 01 / Button 06', 'Mouse 01 / Button 07'
	def x
		$engine.slider_value(X) - 0.5
	end
	def y
		$engine.slider_value(Y) - 0.5
	end
	def click?
		$engine.button_pressed_this_frame?(BUTTON_01)
	end

	def scroll_up?
		$engine.button_pressed_this_frame?(WHEEL_UP)
	end
	def scroll_down?
		$engine.button_pressed_this_frame?(WHEEL_DOWN)
	end
	def scroll_left?
		$engine.button_pressed_this_frame?(WHEEL_LEFT)
	end
	def scroll_right?
		$engine.button_pressed_this_frame?(WHEEL_RIGHT)
	end
end
