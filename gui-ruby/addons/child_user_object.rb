#
# Addons for base class of all "effects" of UserObjects 
#
class ChildUserObject < UserObject
	#
	# Rendering
	#
	def self.gui_render!
		gui_render_label
	end

	def enable_checkbox
		@enable_checkbox ||= GuiToggle.new(self, :enabled).set(:offset_x => 0.45, :offset_y => 0.0, :scale_x => 0.09, :scale_y => 0.9)
	end

	def gui_render!
		gui_render_background
		gui_render_label

		if selected?
			with_positioning {
				enable_checkbox.gui_render!
			}
		end
	end

	def hit_test_render!
		super
		if selected?
			enable_checkbox.hit_test_render!
		end
	end

	#
	# Pointer
	#
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
end
