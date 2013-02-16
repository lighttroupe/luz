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

require 'easy_accessor', 'value_animation', 'value_animation_states'

$LOAD_PATH << './gui-ruby'
require 'pointer', 'pointer_mouse', 'gui_default'

class ProjectEffectEditor < ProjectEffect
	title				"Editor"
	description ""

	setting 'show_amount', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'output_opacity', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'debug', :event
	setting 'gui_color', :color

	def inhibit_hardware?		# TODO: rename hardwire
		true
	end

	def after_load
		super
		@gui = nil
	end

	def luz_2?
		!defined?(GUI)		# the 1.0 Gui manager
	end

	def create_gui
		@gui = GuiDefault.new

		if luz_2?
			$gui = @gui																		# HACK: allows GuiObject and others to send events to the gui, but not in Luz 1.0, while we transition
			$gui.positive_message('Welcome to Luz 2.0')		# and for happy welcome :)
			$application.escape_quits = false
		end

		# TODO: how to configure the mices?
		@pointers = [PointerMouse.new.set_background_image($engine.load_image('images/pointer.png'))]
	end

	def tick
		create_gui unless @gui

		if show_amount > 0.0
			@gui.gui_tick!

			# Perform hit testing-- TODO: this needn't be every frame...
			# Nor full-frame

			#with_offscreen_buffer { |buffer|
			#if @pointers.any? { |p| p.click? } || $env[:frame_number] % 5 == 0		# TODO: or "has moved fast"
				with_hit_testing {				# render in special colors
					@gui.hit_test_render!
					hit_test_pointers
				}
			#}
			#end
			tick_pointers
		end
	end

	def render
		@gui.render {
			with_multiplied_alpha(output_opacity) {
				yield
			}
		}

		if show_amount > 0.0
			with_enter_and_exit(show_amount, 0.0) {
				with_color(gui_color) {
					@gui.gui_render!
				}
				render_pointers
			}
		end

#		@fps_label ||= BitmapFont.new.set(:string => 'FPS', :scale_y => 0.05)
#		@fps_label.set_string(sprintf("%2d FPS", $env[:current_frames_per_second] || 0)) if $env[:frame_number] % 10 == 0
#		@fps_label.gui_render!
	end

	def tick_pointers
		@pointers.each { |pointer| pointer.tick! }
	end

	def render_pointers
		@pointers.each { |pointer| pointer.render! }
	end
 
	def hit_test_pointers
		@pointers.each { |pointer|
			object, _unused_user_data = hit_test_object_at_luz_coordinates(pointer.x, pointer.y)
			pointer.is_over(object)
		}
	end
end
