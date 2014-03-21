
class GuiHBox < GuiBox
	def on_key_press(key)
		return super if key.control?

		case key
		when 'left'
			select_previous!
			selection_grab_focus!
		when 'right'
			select_next!
			selection_grab_focus!
		when 'return'
			selection_grab_focus!
		else
			super
		end
	end
end

class GuiSpacedHBox < GuiHBox
	def each_with_positioning
		step = (1.0 / @contents.count)
		with_positioning {
			@contents.each_with_index { |object, index|
				with_translation(-0.5 + (step/2.0) + (step*index), 0.0) {
					with_scale(step, 1.0) {
						yield object
					}
				}
			}
		}
	end
end
