class GuiList < GuiBox
	easy_accessor :spacing_x, :spacing_y, :item_aspect_ratio

	def with_aspect_ratio_fix
		width = $env[:gui_scale_x]
		height = $env[:gui_scale_y]
		with_scale(1.0, width/height) {		# multiply width as necessary to maintain a ratio of 1x2   TODO: dynamic?
			yield
		}
	end

	def each_with_positioning
		@scroll ||= 0.0
		@scroll += 0.001

		with_positioning {
			with_horizontal_clip_plane_above(0.5) {
				with_horizontal_clip_plane_below(-0.5) {
					final_spacing_y = (spacing_y || 0.0)

					with_translation(0.0, 0.5) {		# start at the top (TODO: or left)
						with_aspect_ratio_fix {
							#puts @scroll if @contents == $engine.project.curves
							with_translation(0.0, @scroll) {		# start at the top (TODO: or left)
								@contents.each_with_index { |gui_object, index|
									with_translation(index * (spacing_x || 0.0), (final_spacing_y / 2.0) + (index * final_spacing_y)) {
										with_scale(1.0, final_spacing_y.abs) {
											yield gui_object
										}
									}
								}
							}
						}
					}
				}
			}
		}
	end

	def gui_render!
		return if hidden?
		with_positioning { with_color([0.5,1.0,0.0,0.5]) { unit_square } }
		each_with_positioning { |gui_object| gui_object.gui_render! }
		
	end

	def hit_test_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.hit_test_render! }
	end
end
