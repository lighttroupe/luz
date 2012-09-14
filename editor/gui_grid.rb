class GuiGrid < GuiBox
	easy_accessor :spacing_x, :spacing_y

	def each_with_positioning
		num_per_row = 3
		with_positioning {
			@contents.each_with_index { |gui_object, index|
				row_index, column_index = index.divmod(num_per_row)
				with_translation(column_index * (@spacing_x || 0.0), row_index * (@spacing_y || 0.0)) {
					yield gui_object
				}
			}
		}
	end

	def gui_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.gui_render! }
	end

	def hit_test_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.hit_test_render! }
	end
end
