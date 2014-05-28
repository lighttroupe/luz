class ActorEffectCanvasInkColorRGBA < ActorEffectCanvas
	virtual		# deprecated

	title				"Canvas Ink Color RGBA"
	description "Choose ink red, green, blue, and alpha manually."

	setting 'red', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'green', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'blue', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'alpha', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def paint(c)
		c.set_source_rgba(red, green, blue, alpha)
		c.set_operator(:source)
	end
end
