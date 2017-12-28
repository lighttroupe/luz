#
# GuiUserObjectClassRenderer renders lists of UserObject classes, ie in the 'add new' popup
#
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
		with_color(LABEL_COLOR) {
			@title_label ||= GuiLabel.new.set(:width => label_width, :scale_y => TITLE_HEIGHT)
			@title_label.string = @object.title
			@title_label.gui_render
		}
	end

	def label_width
		12
	end
end
