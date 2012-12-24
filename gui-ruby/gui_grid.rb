class GuiGrid < GuiBox
	easy_accessor :spacing_x, :spacing_y, :item_scale_x, :item_scale_y, :min_columns

	DEFAULT_MIN_COLUMNS = 3

	def each_with_positioning
		num_per_row = min_columns || DEFAULT_MIN_COLUMNS
		distance_x = (1.0 / num_per_row)
		distance_y = distance_x

		with_positioning {
			@contents.each_with_index { |gui_object, index|
				row_index, column_index = index.divmod(num_per_row)
				with_translation(-0.5 + (distance_x / 2.0) + (column_index * distance_x), 0.5 - (distance_y / 2.0) - (row_index * distance_y)) {
					with_scale((1.0 / num_per_row) * (item_scale_x || 1.0), (1.0 / num_per_row) * (item_scale_y || 1.0)) {
						yield gui_object
					}
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
