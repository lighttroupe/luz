class GuiList < GuiBox
	easy_accessor :spacing_x, :spacing_y

	def each_with_positioning
		with_positioning {
#			with_horizontal_clip_plane_below(-0.5) {
				height = scale_x
				@contents.each_with_index { |gui_object, index|
					with_translation(index * (spacing_x || 0.0), index * (height * (spacing_y || 0.0))) {
						with_scale(1.0, height) { 
							yield gui_object
						}
					}
				}
#			}
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
