class ActorEffectCanvasEraser < ActorEffectCanvas
	virtual		# deprecated

	title				"Canvas Eraser"
	description "A spot eraser, like on the back of a pencil."

	setting 'width', :float, :range => 0.0..2.0, :default => 0.05..2.0
	setting 'x', :float, :range => -1.0..1.0, :default => 0.0..0.5
	setting 'y', :float, :range => -1.0..1.0, :default => 0.0..0.5

	def paint(c)
		return if width == 0.0

		c.save
		c.set_source_rgba(0.0,0.0,0.0,0.0)
		c.set_operator(:source)

		c.move_to(x_setting.last_value, y_setting.last_value)
		c.line_to(x, y)
		c.set_line_width(width)
		c.set_line_cap(:round)
		c.stroke

		c.restore
	end
end
