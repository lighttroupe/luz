class GuiList < GuiBox
	easy_accessor :spacing_x, :spacing_y, :item_aspect_ratio
	easy_accessor :scroll

=begin
	def with_aspect_ratio_fix_y
		width = $env[:gui_scale_x]
		height = $env[:gui_scale_y]
		with_scale(1.0, width/height) {		# multiply width as necessary to maintain a ratio of 1x2   TODO: dynamic?
			with_env(:gui_scale_y, $env[:gui_scale_y] * width/height) {
				yield
			}
		}
	end
=end

	def each_with_positioning
		@scroll ||= 0.0

		with_positioning {
			if spacing_y && spacing_y != 0.0
				with_horizontal_clip_plane_above(0.5) {
					with_horizontal_clip_plane_below(-0.5) {
						final_spacing_y = (spacing_y || 1.0) / (item_aspect_ratio || 1.0)

						with_translation(0.0, 0.5) {
							with_aspect_ratio_fix_y { |fix_y|
								with_translation(0.0, @scroll + (final_spacing_y / 2.0)) {
									first_index, remainder_scroll = @scroll.divmod(final_spacing_y.abs)

									# TODO: determine total_shown
									total_shown = (1.0 / (fix_y * final_spacing_y.abs)).ceil
									total_shown = @contents.size if total_shown > @contents.size

									last_index = first_index + (total_shown) - 1

									for fake_index in first_index..last_index
										index = fake_index % @contents.size		# this achieves endless looping!
										gui_object = @contents[index]
										next unless gui_object

										with_translation(fake_index * (spacing_x || 0.0), (fake_index * final_spacing_y)) {
											with_scale(1.0, final_spacing_y.abs) {
												yield gui_object
											}
										}
									end
								}
							}
						}
					}
				}
			else
				with_vertical_clip_plane_right_of(1.5) {
					with_vertical_clip_plane_left_of(-0.5) {
						final_spacing_x = (spacing_x || 0.0) #/ (item_aspect_ratio || 1.0)

						with_translation(-0.5, 0.0) {
							with_aspect_ratio_fix {
								with_translation(@scroll, 0.0) {
									@contents.each_with_index { |gui_object, index|
										with_translation((final_spacing_x / 2.0) + index * (final_spacing_x), 0.0) {
											with_scale(final_spacing_x.abs, 1.0) {
												yield gui_object
											}
										}
									}
								}
							}
						}
					}
				}
			end
		}
	end

	def gui_render!
		return if hidden?
		#with_positioning { with_color([0.5,1.0,0.0,0.5]) { unit_square } }
		each_with_positioning { |gui_object| gui_object.gui_render! }
		
	end

	def hit_test_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.hit_test_render! }
	end
end
