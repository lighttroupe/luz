 ###############################################################################
 #  Copyright 2008 Ian McIntosh <ian@openanswers.org>
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

require 'conditions'

=begin
	Child Index:
		( ) Every Nth [2 ⟠] Starting at [0 ⟠]
		[ ] Invert

	Event:
		( ) When [event ⟠] () is on () is off

	Context:
		( ) Always
		( ) Studio
		( ) Performance
=end

class ChildConditions < Conditions
	attr_accessor :event, :child_index_min, :child_index_max
	boolean_accessor :enable_child_index, :enable_event, :event_invert

	def to_yaml_properties
		['@enable_child_index', '@child_index_min', '@child_index_max', '@enable_event', '@event', '@event_invert'] + super
	end

	def initialize
		@enable_child_index = false
		@child_index_min = 0
		@child_index_max = 0

		@enable_event = false
		@event = nil
		@event_invert = false
	end

	def satisfied?
		# Apple each rule, if enabled and configured properly
		return false if @enable_event and @event and (@event.now? == (@event_invert == true))		# to deal with possible nil (no after_creation method for non userobjects :/)
		return false if @enable_child_index and ($env[:child_index] < @child_index_min || $env[:child_index] > @child_index_max)
		return true
	end

	def summary_in_pango_markup(highlight_tag = 'u')
		lines = []
		if @enable_event and @event
			lines << ("only while #{@event.title.with_pango_tag(highlight_tag)}" + (@event_invert ? " is off" : " is on"))
		end

		if @enable_child_index
			if @child_index_min == @child_index_max
				lines << ("only child #{@child_index_min + 1}")
			else
				lines << ("only children #{@child_index_min + 1} to #{@child_index_max + 1}")
			end
		end

		if lines.empty?
			''
		else
			'  ' + lines.join("\n  ")
		end
	end
end
