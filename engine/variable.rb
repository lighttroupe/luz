multi_require 'parent_user_object', 'variable_input'

class Variable < ParentUserObject
	title 'Variable'

	DAMPER_AMOUNTS = {:very_low => 0.8, :low => 0.6, :medium => 0.5, :high => 0.3, :very_high => 0.05}

	attr_reader :current_value, :last_value

	setting 'combine_method', :select, :default => :sum, :options => [[:sum, 'Sum'],[:minimum, 'Minimum'],[:maximum, 'Maximum'],[:average, 'Average'],[:product, 'Multiply']]
	setting 'damper_method', :select, :default => :none, :options => [[:none, 'None'],[:very_low, 'Very Low'],[:low, 'Low'],[:medium, 'Medium'],[:high, 'High'],[:very_high, 'Very High']]

	#
	# Class methods
	#
	def self.available_categories
		[:slider, :button, :device, :special]
	end

	#
	# Instance methods
	#
	def default_title
		'New Variable'
	end

	def after_load
		set_default_instance_variables(:current_value => 0.0, :last_value => 0.0)
		super
	end

	def with_value(new_value)
		current_value = @temporary_value
		@temporary_value = new_value.clamp(0.0, 1.0)
		yield
		@temporary_value = current_value
	end

	def do_value
		return @temporary_value unless @temporary_value.nil?
		return 0.0 unless @enabled
		return @current_value if $env[:frame_number] == @last_resolve_frame_number

		user_object_try {
			# Do this FIRST, avoiding infinite recurrsion should one of the inputs refer to this variable
			@last_resolve_frame_number = $env[:frame_number]

			# Save current value
			@last_value = @current_value

			# Resolve new value
			resolve_settings
			@current_value = self.value

			return @current_value
		}
		return 0.0
	end

	def changed?
		@last_value != do_value
	end

	def value
		return damper(combine_inputs(collect_input_values))
	end

	def collect_input_values
		return effects.collect_non_nil { |input| input.do_value if input.usable? }
	end

	def combine_inputs(inputs)
		return inputs.first if inputs.size == 1		# HACK for speed for a very common case
		return 0.0 if inputs.empty?								# Avoids possible divide by 0 later

		case combine_method
		when :sum then return inputs.sum.clamp(0.0, 1.0)
		when :minimum then return inputs.minimum
		when :maximum then return inputs.maximum
		when :average then return inputs.average
		when :product then return inputs.inject(1.0) { |value, new| value * new }
		else
			throw "unknown combine method (#{combine_method})"
		end
	end

	def damper(proposed_value)
		return proposed_value if damper_method == :none
		return linear_damper(proposed_value, DAMPER_AMOUNTS[damper_method])
	end

	def linear_damper(proposed_value, max_change_per_frame)
		@last_value ||= 0.0
		delta_value = proposed_value - @last_value
		return proposed_value.clamp(0.0, 1.0) if delta_value.abs < 0.0001

		max_change_per_frame *= delta_value.abs			# NOTE: as the distance gets smaller, the max change goes down

		if delta_value > max_change_per_frame
			(@last_value + max_change_per_frame).clamp(0.0, 1.0)
		elsif delta_value < -max_change_per_frame
			(@last_value - max_change_per_frame).clamp(0.0, 1.0)
		else
			proposed_value
		end
	end

	def valid_child_class?(klass)
		klass.ancestors.include? VariableInput
	end
end
