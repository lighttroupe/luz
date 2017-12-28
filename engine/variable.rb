multi_require 'parent_user_object', 'variable_input'

class Variable < ParentUserObject
	title 'Variable'

	DAMPER_AMOUNTS = {:very_low => 0.8, :low => 0.6, :medium => 0.5, :high => 0.3, :very_high => 0.05}

	attr_reader :current_value, :last_value

	setting 'combine_method', :select, :default => :sum, :options => [[:sum, 'Sum'],[:minimum, 'Minimum'],[:maximum, 'Maximum'],[:average, 'Average'],[:product, 'Multiply']]
	setting 'max_change_per_frame', :float, :range => 0.0..1.0, :default => 1.0..1.0, :simple => true

	#
	# Class methods
	#
	def self.available_categories
		[:slider, :button, :special]
	end

	#
	# Instance methods
	#
	def new_renderer
		GuiVariableRenderer.new(self)
	end

	def default_title
		''
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
			@last_resolve_frame_number = $env[:frame_number]		# FIRST, avoiding infinite recurrsion should one of the inputs refer to this variable

			# Save current value
			@last_value = @current_value

			# Resolve new value
			resolve_settings
			@current_value = self.value

			return @current_value
		}
		0.0		# In case of exceptions
	end

	def changed?
		@last_value != do_value
	end

	def value
		damper(combine_inputs(collect_input_values))
	end

	def collect_input_values
		effects.collect_non_nil { |input| input.do_value if input.usable? }
	end

	def combine_inputs(inputs)
		return inputs.first if inputs.size == 1		# HACK for speed for a very common case
		return 0.0 if inputs.empty?								# Avoids possible divide by 0 later

		case combine_method
		when :sum then inputs.sum.clamp(0.0, 1.0)
		when :minimum then inputs.minimum
		when :maximum then inputs.maximum
		when :average then inputs.average
		when :product then inputs.inject(1.0) { |value, new| value * new }
		else
			raise "unknown combine method (#{combine_method})"
		end
	end

	def damper(proposed_value)
		return proposed_value if max_change_per_frame == 1.0
		linear_damper(proposed_value, max_change_per_frame)
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
