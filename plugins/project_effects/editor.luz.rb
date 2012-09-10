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
require 'pointer', 'pointer_mouse'
require 'gui_default'

class NilClass		# generally helpful for eg. nil instance variables thought to be holding images
	def using
		yield
	end
end

class UserObject
	empty_method :gui_tick!
	SELECTION_COLOR = [1.0,1.0,1.0,0.25]

	def hit_test_render!
		with_unique_hit_test_color_for_object(self, 0) { unit_square }
	end

	def click(pointer)
		$gui.build_editor_for(self, :pointer => pointer)
	end

	include GuiHoverBehavior
	easy_accessor :selection_scale_x, :selection_scale_y

	def with_selection
		render_selection if pointer_hovering?
		yield
	end

	def render_selection
		with_color(SELECTION_COLOR) {
			with_scale(selection_scale_x || 1.0, selection_scale_y || 1.0) {		# TODO: avoid need for this
				unit_square
			}
		}
	end
end

class Actor
	def gui_render!
		render_selection if pointer_hovering?
		render!
	end
end

class Variable
	GUI_COLOR = [0.0,1.0,0.5,0.7]

	def gui_render!
		render_selection if pointer_hovering?

		# Status Indicator
		with_vertical_clip_plane_right_of(value - 0.5) {
			with_color(GUI_COLOR) {
				unit_square
			}
		}

		# Label
		@title_label ||= BitmapFont.new.set(:string => title, :scale_x => 0.1, :offset_x => -0.5 + 0.08)
		@title_label.gui_render!
	end
end

class Event
	GUI_COLOR_ON = [1.0,1.0,0.0,1.0]
	GUI_COLOR_OFF = [1.0,1.0,0.0,0.1]

	def gui_render!
		render_selection if pointer_hovering?

		# Status Indicator
		with_color(now? ? GUI_COLOR_ON : GUI_COLOR_OFF) {
			unit_square
		}

		# Label
		@title_label ||= BitmapFont.new.set(:string => title, :scale_x => 0.1, :offset_x => -0.5 + 0.08)
		@title_label.gui_render!
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
		@gui = GuiDefault.new
		$gui ||= @gui		# HACK: allows GuiObject and others to send events to the gui

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
