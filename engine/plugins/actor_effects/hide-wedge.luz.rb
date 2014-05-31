class ActorEffectHideWedge < ActorEffect
	title				"Hide Wedge"
	description "Hides a wedge of the actor."

	categories :special

	setting 'wedge_size', :float, :range => 0.0..1.0, :default => 0.0..1.0
	setting 'start_angle', :float, :default => 0.0..1.0

	def render
		# Draw "left" half
		with_clip_plane_right_of_angle(start_angle) {
			with_clip_plane_right_of_angle(start_angle - wedge_size / 2) {
				yield
			}
		}

		# Draw "right" half
		with_clip_plane_left_of_angle(start_angle) {
			with_clip_plane_left_of_angle(start_angle + wedge_size / 2) {
				yield
			}
		}
	end
end
