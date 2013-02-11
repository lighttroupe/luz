class GuiHBox < GuiBox
	def gui_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.gui_render! }
	end

	def hit_test_render!
		each_with_positioning { |gui_object| gui_object.hit_test_render! }
	end

	def each_with_positioning
		step = (1.0 / @contents.count)
		with_positioning {
			@contents.each_with_index { |object, index|
				with_translation((step/2.0) + (step*index), 0.0) {
					with_scale(step, 1.0) {
						yield object
					}
				}
			}
		}
	end
end
