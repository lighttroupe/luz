class ActorEffectCanvasEraseBarVertical < ActorEffectCanvas
	title				"Canvas Erase Bar Vertical"
	description "Erases a vertical strip of the canvas, much like magnetic children's toys."

	setting 'x', :float, :range => -0.5..0.5, :default => -0.5..0.5

	def paint(c)
		unless x == x_setting.last_value
			c.save
				c.set_source_rgba(0.0,0.0,0.0,0.0)
				c.set_operator(:source)
				c.rectangle(x, -0.5, x_setting.last_value - x, 1.0)
				c.fill
			c.restore
		end
	end
end

