class GuiVBox < GuiBox
	def each_with_positioning
		step = (1.0 / @contents.count)
		with_positioning {
			@contents.each_with_index { |object, index|
				with_translation(0.0, 0.5 - (step/2.0) - (step*index)) {
					with_scale(1.0, step) {
						yield object
					}
				}
			}
		}
	end
end
