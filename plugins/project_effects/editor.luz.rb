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

require 'easy_accessor', 'value_animation'
require 'gui_hover_behavior', 'gui_object', 'gui_button', 'gui_box', 'gui_list'
require 'editor/fonts/bitmap-font'
require 'pointer', 'pointer_mouse'
require 'gui_default'

class NilClass		# generally helpful for eg. nil instance variables thought to be holding images
	def using
		yield
	end
end

class UserObject
	empty_method :gui_tick!

	def hit_test_render!
		with_unique_hit_test_color_for_object(self, 0) { unit_square }
	end

	def click(pointer)
		puts "user object '#{title}' clicked"
	end
end

class Actor
	def gui_render!
		render!
	end
end

class Variable
	GUI_COLOR = [0.0,1.0,0.5,0.7]

	def gui_render!
		with_vertical_clip_plane_right_of(value - 0.5) {
			with_color(GUI_COLOR) {
				unit_square
			}
		}
	end
end

class Event
	GUI_COLOR_ON = [0.0,1.0,0.5,0.7]
	GUI_COLOR_OFF = [0.0,1.0,0.0,0.0]

	def gui_render!
		if now? == true
			with_color(GUI_COLOR_ON) {
				unit_square
			}
		else
			with_color(GUI_COLOR_OFF) {
				unit_square
			}
		end
	end
end

class ProjectEffectEditor < ProjectEffect
	title				"Editor"
	description ""

	setting 'show_amount', :float, :range => 0.0..1.0
	setting 'output_opacity', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'debug', :event

	def after_load
		super
		@gui = nil
	end

	def create_gui
		@gui = create_default_gui

		# TODO: how to configure the mices?
		@pointers = [PointerMouse.new.set_background_image($engine.load_image('images/buttons/menu.png'))]
	end

	def tick
		create_gui unless @gui

		@gui.gui_tick!

		if show_amount > 0.0
			# Perform hit testing-- TODO: this needn't be every frame...
			# Nor full-frame

			#with_offscreen_buffer { |buffer|
				with_hit_testing {				# render in special colors
					@gui.hit_test_render!
					hit_test_pointers
				}
			#}
			tick_pointers
		end
	end

	def render
		with_multiplied_alpha(output_opacity) {
			yield
		}

		if show_amount > 0.0
			with_enter_and_exit(show_amount, 0.0) {
				@gui.gui_render!
				render_pointers
			}
		end
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
