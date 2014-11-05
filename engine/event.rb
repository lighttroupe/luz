multi_require 'parent_user_object', 'event_input'

class Event < ParentUserObject
	title 'Event'

	#setting :combine_method, :select, :default => :sum, :options => [[:sum, 'Sum'],[:minimum, 'Minimum'],[:maximum, 'Maximum'],[:average, 'Average'],[:product, 'Multiply']]

	#
	# Class methods
	#
	def self.available_categories
		[:button, :slider, :special]
	end

	#
	# Instance methods
	#
	def default_title
		'New Event'
	end

	attr_reader :count, :last_count

	def after_load
		set_default_instance_variables(:title => default_title, :count => 0, :last_count => 0)
		super
	end

	# This allows plugins to communicate to UserObjects by setting a value for an Event within a block
	def with_value(new_value)
		current_value = @temporary_value
		@temporary_value = new_value
		yield
		@temporary_value = current_value
	end

	def now?
		return @temporary_value unless @temporary_value.nil?		# NOTE: only now? supports this
		@current_value
	end

	def on_this_frame?
		@current_value && !@last_value
	end

	def previous_frame?
		@last_value
	end

	def changed?
		@current_value != @last_value
	end

	def do_value
		user_object_try {
			return false unless enabled?
			return @current_value if $env[:frame_number] == @last_resolve_frame_number

			@last_value = @current_value

			# Do this FIRST, avoiding infinite recurrsion should one of the inputs refer to this variable
			@last_resolve_frame_number = $env[:frame_number]

			resolve_settings

			activation_count = self.value
			@last_count = @count
			@count += activation_count
			@current_value = (activation_count > 0)
			return @current_value
		}
		false		# in case of crash
	end

	def value
		combine_inputs(collect_input_values)
	end

	def valid_child_class?(klass)
		klass.ancestors.include? EventInput
	end

private

	def collect_input_values
		effects.collect_non_nil { |input| input.do_value if input.usable? }
	end

	def combine_inputs(inputs)
		return 0 if inputs.empty?
		inputs.sum
	end
end
