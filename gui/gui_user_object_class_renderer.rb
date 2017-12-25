class GuiUserObjectClassRenderer < GuiObjectRenderer
	LABEL_COLOR = [1,1,1,1]
	TITLE_HEIGHT = 1.0

	#
	# Dragging
	#
	def draggable?
		false
	end

	#
	# Rendering
	#
	def gui_render
		gui_render_background
		gui_render_label
	end

	def gui_render_label
		if pointer_dragging?
			with_translation(SHAKE_DISTANCE * rand, SHAKE_DISTANCE * rand) {
				gui_render_label_internal
			}
		else
			gui_render_label_internal
		end
	end

	def gui_render_label_internal
		with_color(LABEL_COLOR) {
			@title_label ||= GuiLabel.new.set(:width => label_ems, :scale_y => TITLE_HEIGHT)
			@title_label.string = @object.title
			@title_label.gui_render
		}
	end

	def label_ems
		12
	end

	#
	# Pointer
	#
	def click(pointer)
		@parent.child_click(pointer) if @parent
	end
end
