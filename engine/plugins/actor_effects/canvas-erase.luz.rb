class ActorEffectCanvasErase < ActorEffectCanvas
	title				"Canvas Erase"
	description "Erases entire canvas on given event."

	setting 'erase', :event

	def paint(c)
		return unless erase.now?

		c.save
			c.set_source_rgba(0.0,0.0,0.0,0.0)
			c.set_operator(:source)
			c.paint
		c.restore
	end
end
