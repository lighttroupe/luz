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

class ProjectEffectGarbageManager < ProjectEffect
	title				"Garbage Manager"
	description "Allows finer control over Ruby's Garbage Collector."

	hint "You may want to inhibit Garbage Collection while drawing on canvases."

	setting 'inhibit', :event
	setting 'force', :event

	setting 'period', :timespan, :default => [30, :seconds]
	setting 'maximum', :timespan, :default => [1, :minutes]

	def tick
		if force.now?
			#puts "Forced GC @ #{Time.now}..."
			gc_once

		elsif ((@last_gc_time.nil?) or ((Time.now.to_f - @last_gc_time) >= maximum.to_seconds))
			#puts "Safeguard GC @ #{Time.now}..."
			gc_once

		elsif inhibit.now?
			# do nothing-- note that inhibiting is overridden by maximum, but not periodic

		elsif (((Time.now.to_f - @last_gc_time) >= period.to_seconds) && (!period.instant?))
			#puts "Periodic GC @ #{Time.now}..."
			gc_once

		end
	end

	def gc_once
		GC.enable
		GC.start
		GC.disable

		@last_gc_time = Time.now.to_f
	end
end
