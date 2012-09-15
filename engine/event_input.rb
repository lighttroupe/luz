 ###############################################################################
 #  Copyright 2006 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

require 'user_object'

class EventInput < ChildUserObject
	attr_reader :current_value, :last_activation_time		# for use by plugins

	def after_load
		set_default_instance_variables(:current_value => false, :current_value_raw => false, :last_value => false, :last_activation_time => 0.0)
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

			case @current_value_raw
			when true
				@current_value = 1
			when false
				@current_value = 0
			when Integer
				@current_value = @current_value_raw
			else
				throw ArgumentError.new "Event Input plugins should return true, false, or an Integer (got: #{@current_value_raw.class})"
			end

			@last_activation_time = $env[:time] if @current_value > 0
			return @current_value
		}
		return 0	# In case of exceptions
	end

	def changed?
		@current_value != @last_value
	end
end
