class ActorEffectCanvasBrush < ActorEffectCanvas
	title				"Canvas Brush"
	description "Draws as a series of circles."

	setting 'draw', :event

	setting 'x', :float, :range => -1.0..1.0, :default => 0.0..0.5
	setting 'y', :float, :range => -1.0..1.0, :default => 0.0..0.5
	setting 'width', :float, :range => 0.0..2.0, :default => 0.05..2.0
	setting 'distance', :float, :range => 0.001..5.0, :default => 0.02..5.0

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

		if delta_distance > 0.0
			delta_x = x2 - x1
			delta_y = y2 - y1

			# to Unit vectors
			delta_x /= delta_distance
			delta_y /= delta_distance

			step_distance = distance * [width, 0.005].max		# that's about 1 pixel at 1024x768

			unless step_distance == 0.0
				steps = (delta_distance / step_distance).floor
#puts steps
				0.upto(steps) { |i|
					spot_distance = (step_distance * i)
					spot_progress = spot_distance / delta_distance

					spotx = x1 + delta_x * (step_distance * i)
					spoty = y1 + delta_y * (step_distance * i)
					spot_width = spot_progress.scale(w1,w2)

#					unless spot_width == 0.0
						#		c.save

						#			c.save
						#			c.translate(-spotx,-spoty)
						#			c.scale(spot_width, spot_width)
						#			c.set_source(@cairo_pattern)
						#		c.restore

						c.set_operator(:over)
						c.move_to(spotx, spoty)
						c.arc(spotx,spoty, spot_width, 0,2*Math::PI)
						c.fill
	#					c.arc(spotx,spoty, spot_width/2.0, 0,2*Math::PI)
#						c.fill
#						c.arc(spotx,spoty, spot_width/3.0, 0,2*Math::PI)
#						c.fill
#						c.arc(spotx,spoty, spot_width/5.0, 0,2*Math::PI)
#						c.fill
#						end
				}
			end
		end
	end
end
