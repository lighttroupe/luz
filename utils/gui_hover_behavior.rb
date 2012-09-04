module GuiHoverBehavior
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
			puts "pointer enter"
		end
	end

	def pointer_exit(pointer)
		if pointers_hovering.delete(pointer)
			puts "pointer exit"
		end
	end
end
