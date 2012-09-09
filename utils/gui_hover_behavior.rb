module GuiHoverBehavior
	empty_method :on_pointer_enter, :on_pointer_exit, :on_first_pointer_enter, :on_last_pointer_exit

	def pointers_hovering
		@gui_pointers_hovering ||= Set.new
	end

	def pointer_hovering?
		!pointers_hovering.empty?
	end

	def pointer_clicking?
		pointers_hovering.find { |pointer| pointer.click? }
	end

	def pointer_enter(pointer)
		unless pointers_hovering.include?(pointer)
			pointers_hovering << pointer
			on_pointer_enter
			on_first_pointer_enter if pointers_hovering.size == 1
		end
	end

	def pointer_exit(pointer)
		if pointers_hovering.delete(pointer)
			on_pointer_exit
			on_last_pointer_exit if pointers_hovering.empty?
		end
	end
end
