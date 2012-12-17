class ChildUserObject
	def long_click(pointer)
		toggle_enabled!
	end

	def draggable?
		true		# needed for list reordering
	end

	def drag_out(pointer)
		if pointer.drag_delta_y > 0
			parent.move_child_up(self)
		else
			parent.move_child_down(self)
		end
	end

	def gui_render!
		gui_render_background
		gui_render_label
	end
end
