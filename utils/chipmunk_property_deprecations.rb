PROPERTY_DEPRECATIONS = {
	:rotation_control_variable => :rotational_velocity_control_variable,
	:rotation_control_min => :rotational_velocity_control_min,
	:rotation_control_max => :rotational_velocity_control_max,
	:looping_sound_rotational_pitch_min => :looping_sound_rotational_velocity_pitch_min,
	:looping_sound_rotational_pitch_max => :looping_sound_rotational_velocity_pitch_max,
	:spring_resting_length => :spring_length,

	:motor_rate_variable_min => :motor_rate_min,
	:motor_rate_variable_max => :motor_rate_max,
	:motor_force_variable_min => :motor_force_min,
	:motor_force_variable_max => :motor_force_max,

	:activates_on_variable => :activation_variable,

	#:collision_type => :type,
	#:collides_with => :for_type,

	#:overlap_impulse_x => :overlap_force_x,
	#:overlap_impulse_y => :overlap_force_y,
}

def apply_deprecations(object)
	PROPERTY_DEPRECATIONS.each_pair { |deprecated, deprecated_for|
		if (object.options[deprecated])
			puts "*************************************************************"
			puts "** Object '#{object.options[:id]}' has deprecated property"
			puts "**  out: #{deprecated}"
			puts "**   in: #{deprecated_for}"
			puts "*************************************************************"
			object.options[deprecated_for] = object.options.delete(deprecated)
		end
	}
end
