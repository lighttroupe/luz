class ActorEffectActorPen < ActorEffect
	title				'Actor Pen'
	description 'Uses chosen actor as a brush tip, rendering it multiple times per frame to smoothly follow a chosen X,Y point.'

	hint 'This effect is primarily intended for use with the Canvas actor.'

	categories :canvas

	setting 'actor', :actor

	setting 'offset_x', :float, :default => 0.0..1.0
	setting 'offset_y', :float, :default => 0.0..1.0

	setting 'period', :float, :default => 0.01..1.0
	setting 'scale', :float, :default => 1.0..2.0

	setting 'alpha', :float, :default => 1.0..1.0, :range => 0.0..1.0

	setting 'maximum_per_frame', :integer, :range => 1..1000, :default => 50..1000

	def render
		return yield if scale == 0.0

		actor.one { |a|
			parent_user_object.using {
				with_alpha(alpha) {
					prev_x = offset_x_setting.last_value
					prev_y = offset_y_setting.last_value

					delta_x = offset_x - prev_x
					delta_y = offset_y - prev_y

					prev_scale = scale_setting.last_value
					delta_scale = (scale - prev_scale)

					distance = Math.sqrt(delta_x*delta_x + delta_y*delta_y)
					count = ((distance / scale) / period).floor

					count = maximum_per_frame if count > maximum_per_frame

					if count < 2
						with_translation(offset_x, offset_y) {
							with_scale(scale) {
								a.render!
							}
						}
					else
						step_x = delta_x / count
						step_y = delta_y / count

						step_scale = delta_scale / count

						beat_delta = $env[:beat_delta]
						for i in 1..count
							progress = (i.to_f / count)
							with_beat_shift(-beat_delta * (1.0 - progress)) {
								with_translation(prev_x + step_x*i, prev_y + step_y*i) {
									with_scale(prev_scale + step_scale*i) {
										a.render!
									}
								}
							}
						end
					end
				}
			}
		}
		yield
	end
end
