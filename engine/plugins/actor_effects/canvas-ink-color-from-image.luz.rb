class ActorEffectCanvasInkColorFromImage < ActorEffectCanvas
	virtual		# deprecated

	title				"Canvas Ink Color from Image"
	description "Picks an ink color from a chosen X,Y position within a chosen image."

	setting 'palette', :image
	setting 'x', :float, :range => -100.0..100.0, :default => 0.0..1.0
	setting 'y', :float, :range => -100.0..100.0, :default => 0.0..1.0
	setting 'alpha', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'saturation', :float, :range => 0.0..1.0, :default => 1.0..0.0

	def paint(c)
		a = palette.color_at(x % 1.0, y % 1.0).to_a

		# Apply saturation
		s = saturation
		unless s == 1.0
			avg = (a[0] + a[1] + a[2]) / 3.0
			a[0] = s.scale(avg, a[0])
			a[1] = s.scale(avg, a[1])
			a[2] = s.scale(avg, a[2])
		end

		# Apply alpha
		a[3] *= alpha

		c.set_source_rgba(*a)
		c.set_operator(:source)
	end
end
