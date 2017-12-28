#
# GuiVBox splits vertical space evenly amongst @contents
#
class GuiVBox < GuiBox
	def on_key_press(key)
		return super if key.control?
		case key
		when 'up'
			select_previous!
			selection_grab_focus!
		when 'down'
			select_next!
			selection_grab_focus!
		when 'return'
			selection_grab_focus!
		else
			super
		end
	end

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
