class GuiGrid < GuiBox
	easy_accessor :spacing_x, :spacing_y, :item_scale_x, :item_scale_y, :min_columns

	DEFAULT_MIN_COLUMNS = 3

	def each_with_positioning
		num_per_row = column_count
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

	def column_count
		min_columns || DEFAULT_MIN_COLUMNS		# TODO: default value
	end

	def gui_render
		return if hidden?
		each_with_positioning { |gui_object| gui_object.gui_render }
	end

	def hit_test_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.hit_test_render! }
	end

	def select_next!(number=1)
		if (index = selected_index)
			if (index + number) >= @contents.size
				set_selection(@contents.last)
				return
			end
		end
		super
	end

	def select_previous!(number=1)
		if (index = selected_index)
			if (index - number) < 0
				set_selection(@contents.first)
				return
			end
		end
		super
	end

	def on_key_press(key)
		return super if key.control?
		case key
		when 'up'
			select_previous!(column_count)
		when 'down'
			select_next!(column_count)
		when 'left'
			select_previous!
		when 'right'
			select_next!
		else
			super
		end
	end
end
