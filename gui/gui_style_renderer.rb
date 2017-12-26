class GuiStyleRenderer < GuiUserObjectRenderer
	def gui_render
		using_listsafe { unit_square }
	end

	def using_listsafe
		@object.image.using {
			with_color_listsafe(@object.color_setting.color) {		# TODO: seems to be a caching issue with using 'color' directly?
				yield
			}
		}
	end
end
