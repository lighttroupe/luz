class ActorEffectCanvasPenStipple < ActorEffectCanvas
	virtual		# deprecated

	title				"Canvas Pen Stipple"
	description "Draws as dots of a given width, spaced an even distance apart, randomized within a given radius."

	setting 'draw', :event
	setting 'x', :float, :range => -1.0..1.0, :default => 0.0..0.5
	setting 'y', :float, :range => -1.0..1.0, :default => 0.0..0.5
	setting 'width', :float, :range => 0.0..1.0, :default => 0.01..1.0
	setting 'distance', :float, :range => 0.5..10.0, :default => 0.5..10.0
	setting 'radius', :float, :range => 0.005..1.0, :default => 0.005..1.0

	def paint(c)
		return unless draw.now?

		w1 = width_setting.last_value
		w2 = width
		return if w1 == 0.0 and w2 == 0.0

		x1 = x_setting.last_value
		x2 = x

		y1 = y_setting.last_value
		y2 = y

		delta_distance = Math.distance_2d([x1, y1], [x2, y2])

		if delta_distance > 0.0 and width > 0.001
			delta_x = x2 - x1
			delta_y = y2 - y1

			# to Unit vectors
			delta_x /= delta_distance
			delta_y /= delta_distance

			step_distance = distance * width

			unless step_distance == 0.0
				steps = (delta_distance / step_distance).floor
				0.upto(steps) { |i|
					spot_distance = (step_distance * i)
					spot_progress = spot_distance / delta_distance

					centerx = x1 + delta_x * (step_distance * i)
					centery = y1 + delta_y * (step_distance * i)
					spot_width = spot_progress.scale(w1,w2)

					c.set_operator(:over)
					spotx = centerx + rand_in_range(-radius, radius)
					spoty = centery + rand_in_range(-radius, radius)

					c.move_to(spotx, spoty)
					c.arc(spotx,spoty, spot_width, 0,2*Math::PI)
					c.fill
				}
			end
		end
	end
end
