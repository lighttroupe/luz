class GuiStyleRenderer < GuiUserObjectRenderer
	def gui_render
		using_listsafe { unit_square }
	end
end
