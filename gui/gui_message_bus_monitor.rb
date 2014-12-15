#
# Flashes when there is incoming messages, stays lit when messages come really fast
#
class GuiMessageBusMonitor < GuiButton
	FULL_ON_RANGE = 0.0..0.2
	TRANSITION_RANGE = 0.2..0.4
	TRANSITION_TIME = TRANSITION_RANGE.last - TRANSITION_RANGE.first

	def calculate_alpha
		case $env[:time_since_message_bus_activity]
		when FULL_ON_RANGE
			1.0
		when TRANSITION_RANGE
			(1.0 - (($env[:time_since_message_bus_activity] - TRANSITION_RANGE.first) / TRANSITION_TIME)).clamp(0.0, 1.0)
		else
			0.0
		end
	end

	def gui_render
		with_alpha(calculate_alpha) {
			with_gui_object_properties {
				@image.using {
					gui_render_background
				}
			}
		}
	end
end
