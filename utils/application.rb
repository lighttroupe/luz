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

class Application
	EXCEPTION_REPORT_FORMAT = "#{'#' * 80}\n%s#{'#' * 80}"

	def quit
		@running = false
		Gtk.main_quit
	end

	def do_gc
		was_disabled = GC.enable
		start_time = Time.new.to_f
		GC.start
		#puts "GC took #{Time.new.to_f - start_time}"
		GC.disable if was_disabled
	end

	def run
		@running = true
		@frames_since_last_gc = 0

		$settings.on_change('editor-fps') { remove_frame_callback ; @frames_per_second = $settings['editor-fps'] ; create_frame_callback }

		begin
			GC.disable

			section('Running Main Loop') {
				remove_frame_callback
				create_frame_callback
				Gtk.main
			}
		rescue Interrupt
			puts 'Caught Ctrl-C Interrupt'
		rescue SystemExit
			puts 'Caught SystemExit'
		rescue Exception => e
			handle_exception(e)
		end
	end

	def remove_frame_callback
		Gtk.timeout_remove(@frame_callback) if @frame_callback
		@frame_callback = nil
	end

	def create_frame_callback
		@frame_callback = Gtk.timeout_add(1000.0 / @frames_per_second) { do_frame(Time.now.to_f) ; true }
	end

	FRAMES_PER_GC = 200
	def do_frame(time)
		$engine.do_frame(time)
		@frames_since_last_gc += 1
		if(@frames_since_last_gc > FRAMES_PER_GC and gc_now?)
			do_gc
			@frames_since_last_gc = 0
		end
	end

	def gc_now?
		true
	end
end
