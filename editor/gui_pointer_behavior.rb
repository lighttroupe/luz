module GuiPointerBehavior
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
			on_pointer_enter		# TODO: should these take 'pointer' as argument?
			on_first_pointer_enter if pointers_hovering.size == 1
		end
	end

	def pointer_exit(pointer)
		if pointers_hovering.delete(pointer)
			on_pointer_exit
			on_last_pointer_exit if pointers_hovering.empty?
		end
	end
	def child_click(pointer)
		@parent.child_click(pointer) if @parent
	end
	def scroll_left!(pointer)
		parent.scroll_left!(pointer) if parent
	end
	def scroll_right!(pointer)
		parent.scroll_right!(pointer) if parent
	end
	def scroll_up!(pointer)
		parent.scroll_up!(pointer) if parent
	end
	def scroll_down!(pointer)
		parent.scroll_down!(pointer) if parent
	end
end
