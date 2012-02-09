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

require 'user_object_setting_numeric' #, 'curve_combobox', 'curve_combobox_increasing'

class UserObjectSettingFloat < UserObjectSettingNumeric
	attr_reader :last_value

	DEFAULT_RANGE = (-1000.0..1000.0)
	DEFAULT_RANGE_POSITIVE = (0.0..1000.0)

	VALUE_TAB_TITLE = 'Value'
	ACTIVATION_PAGE_TITLE = 'Activation'
	ENTER_PAGE_TITLE = 'Enter'
	EXIT_TAB_TITLE = 'Exit'

	def to_yaml_properties
		super + ['@min', '@max', '@enter_value', '@exit_value', '@enable_enter_animation', '@enter_curve', '@enable_animation', '@animation_curve', '@animation_min', '@animation_max', '@animation_repeat_number', '@animation_repeat_unit', '@enable_exit_animation', '@exit_curve', '@enable_activation', '@activation_direction', '@activation_curve', '@activation_value', '@activation_variable']
	end

	def after_load
		super

		@options[:range] = DEFAULT_RANGE_POSITIVE if @options[:range] == :positive
		@options[:range] = DEFAULT_RANGE if @options[:range].nil?

		@min ||= @options[:range].first
		@max ||= @options[:range].last

		@options[:default] ||= @options[:range]

		@animation_min ||= @options[:default].first.clamp(@min, @max)
		@animation_max ||= @options[:default].last.clamp(@min, @max)

		set_default_instance_variables(
			:enable_enter_animation => false,
			:enter_value => (0.0).clamp(@min, @max),
			:enable_animation => false,
			:animation_repeat_number => 4,
			:animation_repeat_unit => :beats,
			:enable_exit_animation => false,
			:exit_value => (0.0).clamp(@min, @max),
			:enable_activation => false,
			:activation_direction => :to,
			:activation_value => (1.0).clamp(@min, @max),
			:activation_variable => nil)
	end

	def animation_progress(enter_time, enter_beat)
		case @animation_repeat_unit
			when :seconds, :minutes, :hours
				duration = unit_and_number_to_time(@animation_repeat_unit, @animation_repeat_number)
				return (($env[:time] - enter_time) % duration) / duration

			when :beats
				return (($env[:beat] - enter_beat) % (@animation_repeat_number)) / @animation_repeat_number

			else throw "unhandled animation_repeat_unit '#{@animation_repeat_unit}'"
		end
	end

	def widget
		range, step, page, digits = @options[:range], @options[:step] || 0.001, @options[:page] || 0.10, @options[:digits] || 3

		return create_spinbutton(:animation_min, range, step, page, digits) if @options[:simple]

		notebook = Gtk::Notebook.new

		#########################################################################
		# 'Value' page...
		#########################################################################
		animation_curve_combobox = create_curve_combobox(:animation_curve)

		animation_controls_container = Gtk.hbox_for_widgets([
			animation_curve_combobox,

			# Max bound
			create_spinbutton(:animation_max, range, step, page, digits),

			# "every"
			Gtk::Label.new('every'),

			# Number of (beat/second/minute) it repeats/exists
			create_spinbutton(:animation_repeat_number, REPEAT_NUMBER_RANGE, 1.0, 4.0, 2),

			# Beats, Seconds, Minute, ...
			create_combobox(:animation_repeat_unit, TIME_UNIT_OPTIONS)
			])

		value_tab_label = Gtk::Label.new

		# Checkbox which enables later controls
		enable_animation_checkbox = create_checkbox(:enable_animation)
		animation_min_spinbutton = create_spinbutton(:animation_min, range, step, page, digits)

		highlight_value_tab = lambda { animation_min_spinbutton.value != @options[:default].first or enable_animation_checkbox.active? }

		animation_min_spinbutton.on_change {
			if highlight_value_tab.call
				value_tab_label.set_markup(TAB_LABEL_HIGHLIGHT_MARKUP % VALUE_TAB_TITLE)
			else
				value_tab_label.set_markup(TAB_LABEL_MARKUP % VALUE_TAB_TITLE)
			end
		}

		enable_animation_checkbox.on_change_with_init {
			if highlight_value_tab.call
				value_tab_label.set_markup(TAB_LABEL_HIGHLIGHT_MARKUP % VALUE_TAB_TITLE)
			else
				value_tab_label.set_markup(TAB_LABEL_MARKUP % VALUE_TAB_TITLE)
			end

			animation_controls_container.sensitive = ($settings['live-editing'] or enable_animation_checkbox.active?)
			animation_curve_combobox.select_first if animation_curve_combobox.active_object.nil?
			@enable_animation = enable_animation_checkbox.active?
		}

		home_page = append_notebook_page(notebook, value_tab_label, Gtk.hbox_for_widgets([
				animation_min_spinbutton,
				enable_animation_checkbox,
				animation_controls_container
			]))

		#########################################################################
		# 'Activation' page...
		#########################################################################
		activation_curve_combobox = create_curve_combobox_increasing(:activation_curve)

		activation_variable_combobox = create_variable_combobox(:activation_variable)

		new_variable_button = create_new_object_button
		new_variable_button.signal_connect('clicked') {
			$gui.create_parent_user_object(:variable) { |variable|
				activation_variable_combobox.set_active_object(@activation_variable = variable)
			}
		}

		activation_controls_container = Gtk.hbox_for_widgets([
			activation_curve_combobox,

			# "from" / "to"
			create_combobox(:activation_direction, [[:to, 'to'], [:from, 'from']]),

			create_spinbutton(:activation_value, range, step, page, digits),

			#
			Gtk::Label.new('when'),
			activation_variable_combobox, new_variable_button
		])

		# Checkbox which enables later controls
		activation_tab_label = Gtk::Label.new
		enable_activation_checkbox = create_checkbox(:enable_activation)
		enable_activation_checkbox.on_change_with_init {
			activation_tab_label.set_markup(TAB_LABEL_HIGHLIGHT_MARKUP % ACTIVATION_PAGE_TITLE) if enable_activation_checkbox.active?
			activation_tab_label.set_markup(TAB_LABEL_MARKUP % ACTIVATION_PAGE_TITLE) unless enable_activation_checkbox.active?

			activation_controls_container.sensitive = ($settings['live-editing'] or enable_activation_checkbox.active?)
			activation_curve_combobox.select_first if activation_curve_combobox.active_object.nil?
			@enable_activation = enable_activation_checkbox.active?
		}
		append_notebook_page(notebook, activation_tab_label, Gtk.hbox_for_widgets([enable_activation_checkbox, activation_controls_container]))

		#########################################################################
		# 'Enter' page
		#########################################################################
		enter_curve_combobox = create_curve_combobox_increasing(:enter_curve)
		enter_controls_container = Gtk.hbox_for_widgets([
			# Animation curve
			enter_curve_combobox,

			# "from"
			Gtk::Label.new('from'),

			# value
			create_spinbutton(:enter_value, range, step, page, digits),

			# "lasting"
			#Gtk::Label.new('lasting'),

			# Number of (beat/second/minute) it repeats/exists
			#create_spinbutton(:enter_repeat_number, REPEAT_NUMBER_RANGE, 1, 10, 1),

			# Beats, Seconds, Minutes, ...
			#create_combobox(:enter_repeat_unit, TIME_UNIT_OPTIONS)
		])

		# Checkbox which enables later controls
		enter_tab_label = Gtk::Label.new
		enable_enter_animation_checkbox = create_checkbox(:enable_enter_animation)
		enable_enter_animation_checkbox.on_change_with_init {
			enter_tab_label.set_markup(TAB_LABEL_HIGHLIGHT_MARKUP % ENTER_PAGE_TITLE) if enable_enter_animation_checkbox.active?
			enter_tab_label.set_markup(TAB_LABEL_MARKUP % ENTER_PAGE_TITLE) unless enable_enter_animation_checkbox.active?

			enter_controls_container.sensitive = ($settings['live-editing'] or enable_enter_animation_checkbox.active?)
			enter_curve_combobox.select_first if enter_curve_combobox.active_object.nil?
			@enable_enter_animation = enable_enter_animation_checkbox.active?
		}

		append_notebook_page(notebook, enter_tab_label, Gtk.hbox_for_widgets([enable_enter_animation_checkbox, enter_controls_container]))

		#########################################################################
		# 'Exit' page
		#########################################################################
		exit_curve_combobox = create_curve_combobox_increasing(:exit_curve)

		exit_controls_container = Gtk.hbox_for_widgets([
			exit_curve_combobox,

			# "to"
			Gtk::Label.new('to'),

			create_spinbutton(:exit_value, range, step, page, digits),

			# "lasting"
			#Gtk::Label.new('lasting'),

			## Number of (beat/second/minute) it repeats/exists
			#create_spinbutton(:exit_repeat_number, REPEAT_NUMBER_RANGE, 1, 10, 1),

			## "second(s)"  TODO: make this a drop-down
			#create_combobox(:exit_repeat_unit, TIME_UNIT_OPTIONS)
		])

		# Checkbox which enables later controls
		exit_tab_label = Gtk::Label.new
		enable_exit_animation_checkbox = create_checkbox(:enable_exit_animation)
		enable_exit_animation_checkbox.on_change_with_init {
			exit_tab_label.set_markup(TAB_LABEL_HIGHLIGHT_MARKUP % EXIT_TAB_TITLE) if enable_exit_animation_checkbox.active?
			exit_tab_label.set_markup(TAB_LABEL_MARKUP % EXIT_TAB_TITLE) unless enable_exit_animation_checkbox.active?

			exit_controls_container.sensitive = ($settings['live-editing'] or enable_exit_animation_checkbox.active?)
			exit_curve_combobox.select_first if exit_curve_combobox.active_object.nil?
			@enable_exit_animation = enable_exit_animation_checkbox.active?
		}

		append_notebook_page(notebook, exit_tab_label, Gtk.hbox_for_widgets([enable_exit_animation_checkbox, exit_controls_container]))

		return notebook
	end

	def immediate_value
		return @animation_min if @options[:simple]

		# NOTE: Don't do any value caching here, as we need to resolve in various contexts in a single frame
		@last_value = @current_value

		# Get value of animation (any float value)
		if @enable_animation and @animation_curve
			result = @animation_curve.value(animation_progress($env[:birth_time], $env[:birth_beat])).scale(@animation_min, @animation_max)
		else
			result = @animation_min		# Use 'animation_min' as constant value (see the GUI)
		end

		if @enable_activation and @activation_variable
			variable_value = @activation_variable.do_value

			# TODO: special case 0.0 or 1.0?
			if @activation_direction == :from
				result = @activation_curve.value(variable_value).scale(@activation_value, result)
			else # :to
				result = @activation_curve.value(variable_value).scale(result, @activation_value)
			end
		end

		# Enter Animation (scales from enter_value to animation_value on the enter_curve)
		if @enable_enter_animation and @enter_curve
			result = @enter_curve.value($env[:enter]).scale(@enter_value, result)
		end

		# Exit Animation (scales from exit_value to animation_value on the exit_curve)
		if @enable_exit_animation and @exit_curve
			result = @exit_curve.value($env[:exit]).scale(result, @exit_value)
		end

		return (@current_value = result.clamp(@min, @max))	# Never return anything outside (@min to @max)
	end

	# This is just a hack to speed up constant settings
	def hardwire!
		#
		# Setting can be treated as 'simple' (for speed) if it won't ever change value
		#

		# this seems to be causing false positives, remove for now
		#@options[:simple] = true unless (@enable_animation or @enable_activation or @enable_enter_animation or @enable_exit_animation)
	end

	def uses_enter?
		(@enable_enter_animation and @enter_curve)
	end

	def uses_exit?
		(@enable_exit_animation and @exit_curve)
	end
end
