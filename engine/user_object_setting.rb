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

# A setting (color, length) for UserObjects (Actors, Effects)
require 'drawing'

class UserObjectSetting
	include Drawing

	TAB_LABEL_MARKUP = '<small><small>%s</small></small>'
	TAB_LABEL_HIGHLIGHT_MARKUP = '<small><small><span color="white"><u>%s</u></span></small></small>'

	TIME_UNIT_OPTIONS = [[:seconds, 'Seconds'], [:minutes, 'Minutes'], [:hours, 'Hours'], [:beats, 'Beats']]
	REPEAT_NUMBER_RANGE = 0.1..999

	TIME_UNIT_SHORT = {:seconds => 'sec', :minutes => 'mins', :hours => 'hrs', :beats => 'beats'}

	# Called by widget code when something changes.
	callback :change

	attr_accessor :parent
	attr_reader :name, :last_value

	def options=(options)
		@options = options
	end

	def merge_options(options)
		@options.merge!(options)
	end

	def to_yaml_properties
		['@name', '@options', '@breaks_cache']
	end

	def files_used
		[]
	end

	def initialize(parent, name, options={})
		@parent, @name, @options = parent, name, options
		after_load
	end

	empty_method :after_load, :hardwire!, :value			# NOTE: default value returns nil

	def widget(options)
		Gtk::Label.new('Missing controls for editing this setting.')
	end

	def widget_expands?
		false
	end

	def shader?
		@options[:shader] == true
	end

	def get(method)
		instance_variable_get("@#{method}")
	end

	def set(method, value)
		instance_variable_set("@#{method}", value)
		handle_on_change_option
		change_notify
	end

	def handle_on_change_option
		return unless parent
		case @options[:on_change]
		when Symbol
			parent.send @options[:on_change]
		when Proc
			@options[:on_change].call(parent)
		end
	end

	#
	# widget building helpers
	#

	def create_checkbox(method, text=nil)
		button = text ? Gtk::CheckButton.new(text) : Gtk::CheckButton.new
		button.set_active(get(method))
		button.on_change { set(method, button.active?) }
		return button
	end

	def create_toggle(method, text)
		button = Gtk::CheckButton.new(text)
		button.set_active(get(method))
		button.on_change { set(method, button.active?) }
		return button
	end

	def create_radio_buttons_from_values(method, values_array)
		widgets = values_array.collect { |value| Gtk::RadioButton.new }
		widgets.each_with_index { |widget, index|
			widget.group = widgets[0] unless index == 0		# Put all in the same group
		}
		widgets
	end

	def create_new_object_button
		Gtk::Button.new.set_image(Gtk::Image.new(Gtk::Stock::NEW, Gtk::IconSize::MENU)).set_relief(Gtk::RELIEF_NONE).set_focus_on_click(false)
	end

	def create_edit_button
		Gtk::Button.new.set_image(Gtk::Image.new(Gtk::Stock::EDIT, Gtk::IconSize::MENU)).set_relief(Gtk::RELIEF_NONE).set_focus_on_click(false)
	end

	def create_clear_button
		Gtk::Button.new.set_image(Gtk::Image.new(Gtk::Stock::CLEAR, Gtk::IconSize::MENU)).set_relief(Gtk::RELIEF_NONE).set_focus_on_click(false)
	end

	def create_spinbutton(method, range, step, page, digits)
		if range
			spinbutton = Gtk::SpinButton.new(range.first, range.last, step)
		else
			spinbutton = Gtk::SpinButton.new
		end
		spinbutton.set_increments(step, page)
		spinbutton.set_digits(digits)
		spinbutton.set_value(get(method))
		spinbutton.on_change { set(method, ((digits == 0) ? spinbutton.value.to_i : spinbutton.value)) }
		return spinbutton
	end

	def create_curve_combobox(method)
		require 'curve_combobox'
		combobox = CurveComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def create_curve_combobox_increasing(method)
		require 'curve_combobox_increasing'
		combobox = CurveComboBoxIncreasing.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def create_theme_combobox(method)
		require 'theme_combobox'
		combobox = ThemeComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def create_theme_tag_combobox(method)
		require 'theme_tag_combobox'
		combobox = ThemeTagComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def create_actor_combobox(method)
		require 'actor_combobox'
		combobox = ActorComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def create_actor_tag_combobox(method)
		require 'actor_tag_combobox'
		combobox = ActorTagComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def create_director_combobox(method)
		require 'director_combobox'
		combobox = DirectorComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def create_director_tag_combobox(method)
		require 'director_tag_combobox'
		combobox = DirectorTagComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	# Create combobox from [[:one, 'One'],[:two, 'Two']]
	def create_combobox(method, options)
		current_value = get(method)
		combobox = Gtk::ComboBox.new

		# Add rows
		active_index = 0
		options.each_with_index { |pair, index| combobox.append_text(pair.last) ; active_index = index if current_value == pair.first }
		combobox.set_active(active_index)
		combobox.on_change { set(method, options.find { |__index, text| text == combobox.active_text }.first) }
		return combobox
	end

	def create_text_combobox(method, options)
		current_value = get(method)
		combobox = Gtk::ComboBox.new(is_text_only = true)
		active_index = nil
		options.each_with_index {|opt, index|
			active_index = index if opt == current_value
			combobox.append_text(opt)
		}
		combobox.set_active(active_index) if active_index
		combobox.on_change { set(method, combobox.active_text) }
		return combobox
	end

	# TODO: is this used?
	def combobox_value(combobox, options)
		return options[combobox.active].first
	end

	def create_variable_combobox(method)
		require 'variable_combobox'
		combobox = VariableComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def create_event_combobox(method)
		require 'event_combobox'
		combobox = EventComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def create_slider_name_combobox(method)
		require 'slider_name_combobox'
		combobox = SliderNameComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def create_button_name_combobox(method)
		require 'button_name_combobox'
		combobox = ButtonNameComboBox.new
		combobox.set_active_object(get(method))
		combobox.on_change { set(method, combobox.active_object) }
		return combobox
	end

	def append_notebook_page(notebook, label, widget)
		label = Gtk::Label.new.set_markup(TAB_LABEL_MARKUP % label) if label.is_a? String
		notebook.append_page(widget, label)
	end

	def unit_and_number_to_time(unit, number)
		case unit
		when :seconds then return number.to_f
		when :minutes then return number.to_f * 60.0
		when :hours then return number.to_f * 3600.0
		when :beats then return number.to_f / $env[:bps]
		else throw "unhandled time unit '#{unit}'"
		end
	end

	def unit_and_number_to_beats(unit, number)
		case unit
		when :seconds then return $env[:bps]
		when :minutes then return $env[:bps] * 60.0
		when :hours then return $env[:bps] * 3600.0
		when :beats then return number
		else throw "unhandled time unit '#{unit}'"
		end
	end

	def breaks_cache?
		@options[:breaks_cache] || false
	end

	# What a plugin gets when it uses the name of the setting (as it were a local variable, while in fact it is a method)
	def immediate_value
		self
	end

	def uses_enter?
		false
	end

	def uses_exit?
		false
	end

	#
	# Summary
	#
	empty_method :summary

	def summary_format(text)
		return nil unless text

		case @options[:summary]
		when String
			@options[:summary].sub('%', text)
		when TrueClass
			text
		when FalseClass, NilClass
			nil
		else
			puts "user-object-setting warning: unhandled option (:summary) in summary_format: #{@options[:summary]}"
		end
	end
end
