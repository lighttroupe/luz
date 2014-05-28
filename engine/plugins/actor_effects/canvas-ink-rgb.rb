class ActorEffectCanvasInkRGB < ActorEffectCanvas
	virtual		# deprecated

	title				"Canvas Ink RGB"
	description ""

	setting 'red', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'green', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'blue', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def paint(c)
		c.set_source_rgba(red, green, blue, 1.0)
		c.set_operator(:source)
	end
end
