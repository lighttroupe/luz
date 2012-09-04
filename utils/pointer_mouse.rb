class PointerMouse < Pointer
	X,Y,BUTTON_01 = 'Mouse 01 / X', 'Mouse 01 / Y', 'Mouse 01 / Button 01'
	def x
		$engine.slider_value(X) - 0.5
	end
	def y
		$engine.slider_value(Y) - 0.5
	end
	def click?
		$engine.button_pressed_this_frame?(BUTTON_01)
	end
end
