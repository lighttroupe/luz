class Gtk::ColorSelection
	def gl_color
		return [current_color.red, current_color.green, current_color.blue, current_alpha].collect { |n| n.to_f / 65535.0 } if has_opacity_control?
		return [current_color.red, current_color.green, current_color.blue].collect { |n| n.to_f / 65535.0 }
	end
end
