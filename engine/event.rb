 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
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

require 'parent_user_object', 'event_input'

class Event < ParentUserObject
	title 'Event'

	#setting :combine_method, :select, :default => :sum, :options => [[:sum, 'Sum'],[:minimum, 'Minimum'],[:maximum, 'Maximum'],[:average, 'Average'],[:product, 'Multiply']]

	def default_title
		'New Event'
	end

	attr_reader :count, :last_count

	def count
		@count || 0
	end

	def last_count
		@last_count || 0
	end

	def count_changed?
		@count != @last_count
	end

	def after_load
		set_default_instance_variables(:title => default_title, :count => 0, :last_count => 0)
		super
	end

	def now?
		@current_value
	end

	def on_this_frame?
		@current_value and !@last_value
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
		return false		# in case of crash
	end

	def value
		combine_inputs(collect_input_values)
	end

private

	def collect_input_values
		effects.collect_non_nil { |input| input.do_value if input.enabled? }
	end

	def combine_inputs(inputs)
		return 0 if inputs.empty?
		inputs.sum
	end
end
