class Gtk::ColorButton
	def gl_color
		return [color.red, color.green, color.blue, alpha].collect { |n| n.to_f / 65535.0 } if use_alpha?
		return [color.red, color.green, color.blue].collect { |n| n.to_f / 65535.0 }
	end

	def gl_color=(c)
		set_color(Gdk::Color.new(c[0] * 65535.0, c[1] * 65535.0, c[2] * 65535.0))
		set_alpha(c[3] * 65535.0) if use_alpha? and c[3]
	end

	def gl_alpha
		return alpha.to_f / 65535.0
	end

	def on_change
		signal_connect('color-set') { yield }
	end
end
