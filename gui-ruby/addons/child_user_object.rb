#
# Addons for base class of all "effects" of UserObjects 
#
class ChildUserObject < UserObject
	#
	# Rendering
	#
	def self.gui_render!
		gui_render_label
	end

	def enable_checkbox
		@enable_checkbox ||= GuiToggle.new(self, :enabled).set(:offset_x => 0.45, :offset_y => 0.0, :scale_x => 0.09, :scale_y => 0.9)
	end

	def gui_render!
		gui_render_background
		if usable?
			gui_render_label

		else
			with_alpha(0.4) {
				gui_render_label
			}
		end

		gui_render_enable_checkbox
	end

	def gui_render_enable_checkbox
		with_positioning {
			if conditions.enable_event?
				@enable_checkbox.with_positioning {
					with_color([0.9,0.9,0]) {
						unit_square
					}
					unless conditions.event.now?
						with_scale(0.8, 0.9) {
							with_color([0,0,0]) {
								unit_square
							}
						}
					end
				}
			end
			enable_checkbox.gui_render!
		}
	end

	def hit_test_render!
		super
#		if selected?
			enable_checkbox.hit_test_render!
#		end
	end
end
