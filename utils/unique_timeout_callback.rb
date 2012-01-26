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

class UniqueTimeoutCallback
	def initialize(time_in_milliseconds, &proc)
		@time = time_in_milliseconds.to_f
		@repeating = false
		@proc = proc
	end

	#
	# set a timeout, will only call proc ONCE, cancels previous
	#
	def set
		cancel
		@callback_id = Gtk.timeout_add(@time) { @proc.call ; @callback_id = nil ; false }	# false = don't call again
		self
	end

	def cancel
		Gtk.timeout_remove(@callback_id) if @callback_id
		@callback_id = nil
	end

	#
	# start a timeout, will call proc repeatedly until stop is called
	#
	def start
		cancel
		@callback_id = Gtk.timeout_add(@time) { @proc.call ; true }	# true = call again
		self
	end

	def stop
		cancel
	end
end
