require 'user_object'

class EventInput < ChildUserObject
	attr_reader :current_value, :last_activation_time		# for use by plugins

	def self.new_renderer
		GuiUserObjectClassRenderer.new(self)
	end
	def new_renderer
		GuiEventInputRenderer.new(self)
	end

	def after_load
		set_default_instance_variables(:current_value => 0, :current_value_raw => false, :last_value => false, :last_activation_time => 0.0)
		super
	end

	def now?
		@current_value > 0
	end

	def last_value
		@current_value_raw
	end

	def previous_frame?
		@last_value
	end

	def time_since_last_activation
		$env[:time] - @last_activation_time
	end

	def do_value
		return 0 unless enabled?
		return @current_value if $env[:frame_number] == @last_resolve_frame_number

		@last_resolve_frame_number = $env[:frame_number]	# Do this first to avoid any possible recurrsion issues.
		@last_value = @current_value

		resolve_settings

		user_object_try {
			@current_value_raw = self.value
			@current_value = clean_value(@current_value_raw)
			@last_activation_time = $env[:time] if @current_value > 0
			return @current_value
		}
		0		# In case of exceptions
	end

	def changed?
		@current_value != @last_value
	end

private

	def clean_value(value)
		case value
		when true
			1
		when false
			0
		when Integer
			value
		else
			raise "Event Input plugins should return true, false, or an Integer (got: #{value.class})"
		end
	end
end
