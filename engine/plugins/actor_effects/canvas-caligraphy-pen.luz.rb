class ActorEffectCanvasCaligraphyPen < ActorEffectCanvas
	title				"Canvas Caligraphy Pen"
	description "Draws with a flat-tipped pen."

	setting 'draw', :event
	setting 'width', :float, :range => 0.0..2.0, :default => 0.05..2.0
	setting 'x', :float, :range => -1.0..1.0, :default => -0.5..0.5
	setting 'y', :float, :range => -1.0..1.0, :default => -0.5..0.5

	def paint(c)
		return unless draw.now? or draw.previous_frame?

		# Decide widths of the line at previous and current point
		if draw.now?
			w2_prev = width_setting.last_value / 2.0
			w2 = width / 2.0
		elsif draw.previous_frame?
			w2_prev = width_setting.last_value / 2.0
			w2 = 0.0
		end

		c.move_to(x_setting.last_value, y_setting.last_value - w2_prev)
		c.line_to(x, y - w2)
		c.line_to(x, y + w2)
		c.line_to(x_setting.last_value, y_setting.last_value + w2_prev)
		c.close_path
		c.fill
	end
end
