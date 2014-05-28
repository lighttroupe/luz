class ActorEffectInspect < ActorEffect
	title				'Inspect'
	description "Zoom in and pan on an actor while keeping it entirely on screen."

	category :transform

	setting 'zoom', :float, :default => 1.0..2.0
	setting 'x', :float, :range => -0.5..0.5, :default => 0.0..0.5
	setting 'y', :float, :range => -0.5..0.5, :default => 0.0..0.5

	def render
		# When zoom is 1.0, we can't translate at all.
		# When zoom is 2.0, we can translate exactly 0.5.
		# When zoom is 3.0, we must translate 1.0 to reach the border, etc.
		with_translation(-x * (zoom - 1.0), -y * (zoom - 1.0)) {		# NOTE: negate x and y because they mean "go" and not "move"
			with_scale(zoom) {
				yield
			}
		}
	end
end
