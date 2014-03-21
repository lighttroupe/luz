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

multi_require 'easy_accessor', 'value_animation', 'value_animation_states'

$LOAD_PATH << './gui'
multi_require 'pointer', 'pointer_mouse', 'gui_default'

class ProjectEffectEditor < ProjectEffect
	title				"Editor"
	description ""

	setting 'alpha', :float, :range => 0.1..1.0, :default => 1.0..1.0

	def inhibit_hardware?		# TODO: rename hardwire
		true
	end

	def after_load
		super
		@gui = nil
		$engine.project.each_user_object { |user_object| user_object.clear_selection! if user_object.respond_to? :clear_selection! }
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

		unless @gui.hidden? or alpha == 0.0
			@gui.gui_tick!

			# TODO: only do hit testing when needed (NOTE: needed for hover as well as click response)
			with_hit_testing {
				@gui.hit_test_render!
				hit_test_pointers
			}
			tick_pointers
		end
	end

	def render
		with_alpha(alpha) {
			@gui.render {
				with_alpha(1.0) {
					yield
				}
			}
		}
		render_pointers unless @gui.hidden?
	end

	def tick_pointers
		@pointers.each(&:tick!)
	end

	def render_pointers
		@pointers.each(&:render!)
	end
 
	def hit_test_pointers
		@pointers.each { |pointer|
			object, _unused_user_data = hit_test_object_at_luz_coordinates(pointer.x, pointer.y)
			pointer.is_over(object)
		}
	end
end
