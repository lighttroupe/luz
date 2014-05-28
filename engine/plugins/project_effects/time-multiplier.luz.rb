class ProjectEffectTimeMultiplier < ProjectEffect
	title				'Time Multiplier'
	description "Multiplies the rate at which time passes by the given amount."

	hint "The default rate is 1.0, one engine second for each real-world second. A rate of 2.0 means twice as fast. If the rate drops below 0.0, engine time will run in reverse."

	setting 'amount', :float, :range => -100.0..100.0, :default => 1.0..100.0

	# TODO: this should use with_env() block when tick supports yield

	def pretick
		@previous_simulation_speed = $engine.simulation_speed
		$engine.simulation_speed *= amount
	end

	def tick
		$engine.simulation_speed = @previous_simulation_speed
	end
end
