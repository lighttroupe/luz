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

	def render!
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

	def render!
		with_positioning {
			@contents.each { |gui_object|
				gui_object.render!
			}
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

	def render!
		each_with_positioning { |gui_object| gui_object.render! }
	end

	def debug_render!
		each_with_positioning { |gui_object| gui_object.debug_render! }
	end
end

class Actor
	def debug_render!
		with_unique_hit_test_color_for_object(self, 0) { unit_square }
	end
end

class Variable
	GUI_COLOR = [0.0,1.0,0.5,0.7]
	def render!
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
		super
	end

	def render
		#
		if debug.now?		# hit test
			with_hit_test {
				@gui.debug_render!
			}
		else
			with_multiplied_alpha(output_opacity) {
				yield
			}

			if show_amount > 0.0
				with_enter_and_exit(show_amount, 0.0) {
					@gui.render!
				}
			end
		end
	end
end
