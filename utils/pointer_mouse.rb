class PointerMouse < Pointer
	def x_name
		@x_name ||= sprintf("Mouse %02d / X", number)
	end

	def y_name
		@y_name ||= sprintf("Mouse %02d / Y", number)
	end

	def button_one_name
		@button_one_name ||= sprintf("Mouse %02d / Button 01", number)
	end

	def scroll_up_name
		@scroll_up_name ||= sprintf("Mouse %02d / Button 04", number)
	end

	def scroll_down_name
		@scroll_down_name ||= sprintf("Mouse %02d / Button 05", number)
	end

	def scroll_left_name
		@scroll_left_name ||= sprintf("Mouse %02d / Button 06", number)
	end

	def scroll_right_name
		@scroll_right_name ||= sprintf("Mouse %02d / Button 07", number)
	end
end
