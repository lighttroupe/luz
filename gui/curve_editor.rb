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

class CurveEditor < Gtk::VBox
	VECTOR_POINTS = 9
	APPROXIMATION_POINTS = 200
	DAMPER_VALUE = 0.005		# An important point less than this distance from an important number will be moved to that number (see apply_damper)
	IMPORTANT_VALUES = [0.0, 0.5, 1.0]
	DEFAULT_VECTOR = [0.0, 1.0]

	callback :change

	def initialize
		super

		# Create curve
		@curve = Gtk::Curve.new.reset
		self.pack_start(@curve, expand = true, fill = true, padding = 0)

		@curve_type = Gtk::Curve::TYPE_SPLINE

		# Create buttons
		@controls_hbox = Gtk::HBox.new.set_spacing(6)
		self.pack_start(@controls_hbox, expand = false, fill = true, padding = 0)

		# linear button
		@linear_button = Gtk::Button.new('Linear').set_relief(Gtk::RELIEF_NONE) #.set_image(Gtk::Image.new('gtk-jump-to', Gtk::IconSize::MENU))
		@linear_button.on_click { @curve.reset }
		@controls_hbox.pack_start(@linear_button, expand = false, fill = false)

		# 50% button
		@half_button = Gtk::Button.new('50%').set_relief(Gtk::RELIEF_NONE) #.set_image(Gtk::Image.new('gtk-undo', Gtk::IconSize::MENU))
		@half_button.on_click { @curve.reset ; set_vector([0.5, 0.5]) }
		@controls_hbox.pack_start(@half_button, expand = false, fill = false)

		# ---spacer---
		@controls_hbox.pack_start(Gtk::Label.new, expand = true, fill = true)

		# invert button
		@invert_button = Gtk::Button.new('Invert').set_relief(Gtk::RELIEF_NONE)
		@invert_button.on_click { set_vector(get_vector.collect { |y| 1.0 - y }) }
		@controls_hbox.pack_start(@invert_button, expand = false, fill = false)

		# apply button
		@apply_button = Gtk::Button.new('Apply')
		@apply_button.on_click { change_notify(get_vector(VECTOR_POINTS), get_vector(APPROXIMATION_POINTS)) }
		@controls_hbox.pack_start(@apply_button, expand = false, fill = false)

		show_all
	end

	def create_for(object)
		set_vector(object.approximation)
		@object = object
	end

	def update_object(object)
		create_for(object) if object == @object
	end

private

	def get_vector(num_points = VECTOR_POINTS)
		v = @curve.get_vector(num_points)

		# damper important points (0, 1/4, 1/2, 3/4, 1)
		[0, (num_points / 4) * 1, (num_points / 4) * 2, (num_points / 4) * 3, num_points - 1].each { |i| v[i] = apply_damper(v[i]) }

		return v
	end

	def set_vector(vector)
		@curve.set_curve_type(@curve_type)
		@curve.set_vector(vector.size, vector)
		@curve.reset if vector == DEFAULT_VECTOR
		@curve.set_curve_type(@curve_type)
	end

	def apply_damper(value)
		v = value
		IMPORTANT_VALUES.each { |important_value| v = v.damper(important_value, DAMPER_VALUE) }
		return v
	end
end

