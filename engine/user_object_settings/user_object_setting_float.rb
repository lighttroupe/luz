require 'user_object_setting_numeric'

class UserObjectSettingFloat < UserObjectSettingNumeric
	DEFAULT_RANGE = (-1000.0..1000.0)

	ACTIVATION_DIRECTION_OPTIONS = [[:to, 'to'], [:from, 'from']]

	PARAMS = [:min, :max, :enter_value, :exit_value, :enable_enter_animation, :enter_curve, :enable_animation, :animation_curve, :animation_min, :animation_max, :animation_repeat_number, :animation_repeat_unit, :enable_exit_animation, :exit_curve, :enable_activation, :activation_direction, :activation_curve, :activation_value, :activation_variable]
	attr_accessor *PARAMS

	def to_yaml_properties
		super + ['@min', '@max', '@enter_value', '@exit_value', '@enable_enter_animation', '@enter_curve', '@enable_animation', '@animation_curve', '@animation_min', '@animation_max', '@animation_repeat_number', '@animation_repeat_unit', '@enable_exit_animation', '@exit_curve', '@enable_activation', '@activation_direction', '@activation_curve', '@activation_value', '@activation_variable']
	end

	def after_load
		super

		# range is the hard limit: we won't return values outside the range
		@options[:range] ||= DEFAULT_RANGE
		@min ||= @options[:range].first
		@max ||= @options[:range].last

		@options[:default] ||= @options[:range]
		@animation_min ||= @options[:default].first.clamp(@min, @max)
		@animation_max ||= @options[:default].last.clamp(@min, @max)

		@enter_curve ||= $engine.project.curves.first
		@exit_curve ||= @enter_curve
		@animation_curve ||= @enter_curve
		@activation_curve ||= @enter_curve

		set_default_instance_variables(:enable_enter_animation => false, :enter_value => (0.0).clamp(@min, @max), :enable_animation => false, :animation_repeat_number => 4, :animation_repeat_unit => :beats, :enable_exit_animation => false, :exit_value => (0.0).clamp(@min, @max), :enable_activation => false, :activation_direction => :to, :activation_value => (1.0).clamp(@min, @max), :activation_variable => nil)
	end

	def immediate_value
		return @animation_min if @options[:simple]

		# NOTE: Don't do any value caching here, as we need to resolve in various contexts in a single frame
		@last_value = @current_value

		# Get value of animation (any float value)
		if @enable_animation && @animation_curve
			result = @animation_curve.value(animation_progress($env[:birth_time], $env[:birth_beat])).scale(@animation_min, @animation_max)
		else
			result = @animation_min		# Use 'animation_min' as constant value (see the GUI)
		end

		if @enable_activation && @activation_variable
			variable_value = @activation_variable.do_value

			# TODO: special case 0.0 or 1.0?
			if @activation_direction == :from
				result = @activation_curve.value(variable_value).scale(@activation_value, result)
			else # :to
				result = @activation_curve.value(variable_value).scale(result, @activation_value)
			end
		end

		# Enter Animation (scales from enter_value to animation_value on the enter_curve)
		if @enable_enter_animation && @enter_curve
			result = @enter_curve.value($env[:enter]).scale(@enter_value, result)
		end

		# Exit Animation (scales from exit_value to animation_value on the exit_curve)
		if @enable_exit_animation && @exit_curve
			result = @exit_curve.value($env[:exit]).scale(result, @exit_value)
		end

		return (@current_value = result.clamp(@min, @max))	# Never return anything outside (@min to @max)
	end

	def last_value
		@last_value || @min
	end

	def uses_enter?
		@enable_enter_animation && !@enter_curve.nil?
	end

	def uses_exit?
		@enable_exit_animation && !@exit_curve.nil?
	end

private

	def animation_progress(enter_time, enter_beat)
		case @animation_repeat_unit
		when :seconds, :minutes, :hours
			duration = unit_and_number_to_time(@animation_repeat_unit, @animation_repeat_number)
			(($env[:time] - enter_time) % duration) / duration
		when :beats
			(($env[:beat] - enter_beat) % @animation_repeat_number) / @animation_repeat_number
		else
			raise "unhandled animation_repeat_unit '#{@animation_repeat_unit}'"
		end
	end
end
