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

require 'user_object_setting'

class UserObjectSettingTimespan < UserObjectSetting
	attr_accessor :time_number, :time_unit

	def to_yaml_properties
		['@time_number', '@time_unit'] + super
	end

	def after_load
		@time_number ||= (@options[:default] ? @options[:default][0] : (4))
		@time_unit ||= (@options[:default] ? @options[:default][1] : (:seconds))
	end

	def widget
		time_number = create_spinbutton(:time_number, 0.0..999.0, 1, 10, 3)
		time_unit = create_combobox(:time_unit, TIME_UNIT_OPTIONS)

		return Gtk.hbox_for_widgets([time_number, time_unit])
	end

	attr_reader :time_number, :time_unit

	def instant?
		@time_number == 0
	end

	def to_seconds
		unit_and_number_to_time(@time_unit, @time_number)
	end

	def progress_since(time)
		return 1.0 if instant?

		elapsed = $env[:time] - time
		elapsed = elapsed.abs		# NOTE: progress backwards in time works just as well

		return (elapsed / self.to_seconds).clamp(0.0, 1.0)
	end

	def delta
		return 1.0 if @time_number == 0.0

		if @time_unit == :beats
			$env[:beat_delta] / @time_number
		else
			$env[:time_delta] / @time_number
		end
	end

	def summary
		summary_format("#{@time_number} #{TIME_UNIT_SHORT[@time_unit]}")
	end
end
