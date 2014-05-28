class ActorEffectCanvasInkColor < ActorEffectCanvas
	virtual		# deprecated

	title				"Canvas Ink Color"
	description "Sets color of ink."

	hint "Use this before plugins that draw."

	setting 'color', :color, :default => [1.0, 1.0, 1.0, 1.0]

	def paint(c)
		c.set_source_rgba(*color.to_a)
		c.set_operator(:source)
	end
end
