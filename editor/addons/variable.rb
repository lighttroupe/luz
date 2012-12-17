class Variable
	GUI_COLOR = [0.0,1.0,0.5,0.7]
	MARKER_COLOR = [0.8,0.0,0.0,0.15]

	def gui_render!
		gui_render_background

		# Status Indicator
		#with_vertical_clip_plane_right_of(value - 0.5) {
		if (v=do_value) > 0.0
			with_translation(-0.5 + v/2.0, 0.0) {
				with_scale_unsafe(v, 1.0) {
					with_color(GUI_COLOR) {
						unit_square
					}
				}
			}
		end

		#Value Display
		with_translation(0.45, 0.25) {
			@value_label ||= BitmapFont.new.set(:scale_x => 0.35, :scale_y => 0.35)
			@value_label.set_string((value * 100).to_i.to_s + '%')
			@value_label.gui_render!
		}

		# Status Marker
		#with_translation(0.0, -0.4) {
		#	with_scale(0.01, 0.25) {
		#		with_color(MARKER_COLOR) {
		#			unit_square
		#		}
		#	}
		#}
		#with_translation(0.25, -0.45) {
		#	with_scale(0.01, 0.15) {
		#		with_color(MARKER_COLOR) {
		#			unit_square
		#		}
		#	}
		#}
		#with_translation(-0.25, -0.45) {
		#	with_scale(0.01, 0.15) {
		#		with_color(MARKER_COLOR) {
		#			unit_square
		#		}
		#	}
		#}

		# Label
		gui_render_label
	end
end
