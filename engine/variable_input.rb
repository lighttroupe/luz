require 'user_object'

class VariableInput < ChildUserObject
	attr_reader :current_value, :last_value

	def after_load
		set_default_instance_variables(:current_value => 0.0, :last_value => 0.0)
		super
	end

	def do_value
		return 0.0 unless enabled?
		return @current_value if $env[:frame_number] == @last_resolve_frame_number

		@last_resolve_frame_number = $env[:frame_number]	# Do this first to avoid any possible recurrsion issues.

		@last_value = @current_value

		resolve_settings
		user_object_try {
			@current_value = (value || 0.0).clamp(0.0, 1.0)
			return @current_value
		}

		0.0	# In case of exceptions
	end

	def changed?
		@current_value != @last_value
	end
end
