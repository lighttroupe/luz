class ActorEffectCanvasErasePartial < ActorEffectCanvas
	virtual		# deprecated

	title				"Canvas Erase Partial"
	description "Clears the canvas a given amount."

	setting 'amount', :float, :range => 0.0..1.0, :default => 0.0..1.0

	def paint(c)
		unless amount == 0.0
			c.save
				c.set_source_rgba(0.0,0.0,0.0,0.0)
				c.set_operator(:source)
				c.paint(amount) # * $env[:frame_time_delta])		# TODO: multiply by elapsed time ?
			c.restore
		end
	end
end

