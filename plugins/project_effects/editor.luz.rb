 ###############################################################################
 #  Copyright 2011 Ian McIntosh <ian@openanswers.org>
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

#require 'cycle-logic'
#require 'safe_eval'
require 'easy_accessor'

=begin
GuiRectangle = Struct.new(:top, :right, :bottom, :left)

def with_gui_viewport(rect)		# inspired by CSS
	rect = $env[:gui_viewport] ? $env[:gui_viewport].dup : GuiRectangle.new(0.5, 0.5, -0.5, -0.5)
	with_env(:gui_viewport, rect) {
		yield
	}
end
=end

class GuiObject
	attr_accessor :parent
	easy_accessor :offset_x, :offset_y, :scale_x, :scale_y

	def initialize
		@offset_x, @offset_y = 0.0, 0.0
		@scale_x, @scale_y = 1.0, 1.0
		@parent = nil
	end

	def set_scale(scale)
		@scale_x, @scale_y = scale, scale
	end

	def gui_render!
	end

	def debug_render!
		with_unique_hit_test_color_for_object(self, 0) { unit_square }
	end

	def with_positioning
		with_translation(@offset_x, @offset_y) {
			with_scale(@scale_x, @scale_y) {
				yield
			}
		}
	end
end

class GuiBox < GuiObject
	def initialize(contents = [])
		@contents = contents
		super()
	end

	def <<(gui_object)
		@contents << gui_object
		gui_object.parent = self
	end

	def gui_render!
		with_positioning {
			@contents.each { |gui_object| gui_object.gui_render! }
		}
	end

	def debug_render!
		with_positioning {
			@contents.each { |gui_object|
				if gui_object.respond_to?(:debug_render!)
					gui_object.debug_render!
				end
			}
		}
	end

=begin
	def self.init_env
		$env[:gui_box_top] = 0.5
		$env[:gui_box_right] = 0.5
		$env[:gui_box_bottom] = -0.5
		$env[:gui_box_left] = -0.5
	end
=end
end

class GuiList < GuiBox
	easy_accessor :spacing

	def each_with_positioning
		with_positioning {
			@contents.each_with_index { |gui_object, index|
				with_translation(0.0, index * (-1.0 - (@spacing || 0.0))) {
					yield gui_object
				}
			}
		}
	end

	def gui_render!
		each_with_positioning { |gui_object| gui_object.gui_render! }
	end

	def debug_render!
		each_with_positioning { |gui_object| gui_object.debug_render! }
	end
end

class Actor
	def gui_render!
		render!
	end

	def debug_render!
		with_unique_hit_test_color_for_object(self, 0) { unit_square }
	end

	def click(pointer)
		#puts "actor clicked"
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

	def debug_render!
		with_unique_hit_test_color_for_object(self, 0) {
			unit_square
		}
	end

	def click(pointer)
		#puts "variable clicked"
	end
end

class Pointer
	attr_accessor :number

	def initialize
		@number = 1
	end

	def tick
		if @hover_object && click?
			@hover_object.click(self) if @hover_object.respond_to?(:click)
		end
	end

	def is_over(object)
		return if @hover_object == object

		exit_hover_object!

		if object
			# enter new object
			object.pointer_enter(self) if object.respond_to?(:pointer_enter)

			# save
			@hover_object = object
			#puts "hovering over #{@hover_object.title}"
		end
		self
	end

	def exit_hover_object!
		@hover_object.pointer_exit(self) if @hover_object && @hover_object.respond_to?(:pointer_exit)
		@hover_object = nil
	end
end

class PointerMouse < Pointer
	X,Y,BUTTON_01 = 'Mouse 01 / X', 'Mouse 01 / Y', 'Mouse 01 / Button 01'
	def x
		$engine.slider_value(X) - 0.5
	end
	def y
		$engine.slider_value(Y) - 0.5
	end
	def click?
		$engine.button_pressed_this_frame?(BUTTON_01)
	end
end

class ProjectEffectEditor < ProjectEffect
	include CycleLogic

	title				"Editor"
	description ""

	setting 'show_amount', :float, :range => 0.0..1.0
	setting 'output_opacity', :float, :range => 0.0..1.0, :default => 1.0..1.0
	setting 'debug', :event

	def after_load
		@gui = GuiBox.new
		@gui << GuiList.new($engine.project.actors).set_scale_x(0.2).set_scale_y(0.2).set_offset_x(-0.4).set_offset_y(0.4)
		@gui << GuiList.new($engine.project.variables).set_scale_x(0.15).set_scale_y(0.04).set_offset_x(-0.20).set_offset_y(0.45).set_spacing(0.4)

		@pointers = [PointerMouse.new]
		super
	end

	def render
		#
		if show_amount > 0.0
			with_hit_test {
				@gui.debug_render!
			}
			hit_test_pointers
		end

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

	def render_pointers
		with_color([1,1,1]) {
			@pointers.each { |pointer|
				with_translation(pointer.x, pointer.y) {
					with_scale(0.05) {
						unit_square
					}
				}
			}
		}
	end
 
	def hit_test_pointers
		@pointers.each { |pointer|
			object, _unused_user_data = hit_test_object_at_luz_coordinates(pointer.x, pointer.y)
			pointer.is_over(object)
			pointer.tick
		}
	end
end
