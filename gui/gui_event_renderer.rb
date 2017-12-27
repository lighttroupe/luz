class	GuiEventRenderer < GuiUserObjectRenderer
	COLOR_ON = [0.3,0.3,0.0,1.0]
	COLOR_OFF = [1.0,1.0,0.0,0.0]

	def gui_render
		gui_render_background
		gui_render_label
	end

	def background_color
		if @object.now?
			COLOR_ON
		else
			COLOR_OFF
		end
	end

private

	def label_width
		9
	end
end
