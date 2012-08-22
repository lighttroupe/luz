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
		with_positioning {
			unit_square_outline
		}
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
		@contents.each { |gui_object| gui_object.debug_render! if gui_object.respond_to? :debug_render! }
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
	def render!
		with_positioning {
			@contents.each_with_index { |gui_object, index|
				with_translation(0.0, index * -1.0 * $env[:enter]) {
					gui_object.render!
				}
			}
		}
	end
end

class ProjectEffectEditor < ProjectEffect
	include CycleLogic

	title				"Editor"
	description ""

	setting 'show_amount', :float, :range => 0.0..1.0
	setting 'output_opacity', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def after_load
		@gui = GuiBox.new
		@gui << GuiList.new($engine.project.actors).set_scale_x(0.2).set_scale_y(0.2).set_offset_x(-0.6).set_offset_y(0.6)
		super
	end

	def render
		if show_amount > 0.0
			with_enter_and_exit(show_amount, 0.0) {
				#@gui.debug_render!
				@gui.render!
			}
		end

		with_multiplied_alpha(output_opacity) {
			yield
		}
	end
end
