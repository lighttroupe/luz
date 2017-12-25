class GuiUserObjectRenderer < GuiObjectRenderer
	LABEL_COLOR_CRASHY = [1,0,0,0.35]
	LABEL_COLOR_EVENT_OFF = [1,1,0,0.35]
	LABEL_COLOR_DISABLED = [1,1,1,0.35]
	LABEL_COLOR = [1,1,1,1]
	USER_OBJECT_TITLE_HEIGHT = 1.0

	SHAKE_DISTANCE = 0.007

	#
	# Class level
	#
	extend Drawing
	def self.gui_render_label
		with_color(LABEL_COLOR) {
			@@class_title_label ||= Hash.new { |hash, key| hash[key] = GuiLabel.new.set(:width => 14, :string => key, :scale_x => 0.95, :scale_y => USER_OBJECT_TITLE_HEIGHT) }
			@@class_title_label[title].gui_render
		}
	end

	#
	# Dragging
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

	def hit_test_render!
		with_unique_hit_test_color_for_object(self) { unit_square }
	end

	def gui_render_label_internal
		with_color(label_color) {
			@title_label ||= GuiLabel.new.set(:width => label_ems, :scale_y => USER_OBJECT_TITLE_HEIGHT)
			@title_label.string = @object.title
			@title_label.gui_render
		}
	end

	def label_ems
		12
	end

	def label_color
		if @object.crashy?
			LABEL_COLOR_CRASHY
		elsif !@object.usable?
			LABEL_COLOR_UNUSABLE
		else
			LABEL_COLOR
		end
	end
end
