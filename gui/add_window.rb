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

require 'glade_window', 'user_object_class_treeview'

class AddWindow < GladeWindow
	TITLE_MARKUP_FORMAT = "<big><big><b>%s</b></big></big>"
	DESCRIPTION_MARKUP_FORMAT = "%s"

	DEFAULT_TITLE = '<span color="#ff2222">Title missing.</span>'
	DEFAULT_DESCRIPTION = '<span color="#ff2222">Description missing.</span>'

	EMPTY_TITLE = 'No Selection'
	EMPTY_DESCRIPTION = 'Select an item from the list.'

	pipe :add_class, :class_treeview, :method => :add			# Called by engine to tell us about new classes

	def initialize(title = '')
		super('add_window')

		$gui.on_reload { on_selection(@selected_class) if @selected_class }

		on_key_press(Gdk::Keyval::GDK_Return) { activate_default }
		on_key_press(Gdk::Keyval::GDK_Escape) { hide }
		on_lose_focus { hide }

		# Class Treeview
		@class_treeview = UserObjectClassTreeView.new.show
		@class_treeview_container.add(@class_treeview)
		@class_treeview.on_selection_change {
			classes = @class_treeview.selected
			if classes.size == 1
				on_selection(classes.first)
			else
				on_no_selection
			end
			has_selection = classes.size > 0

			@ok_button.sensitive = has_selection
			@edit_source_button.sensitive = has_selection
			@name_label.sensitive = has_selection
			@description_label.sensitive = has_selection
		}

		@class_treeview.on_activated { activate_default ; true }  # handled

		@class_treeview.set_search_equal_func { |model, columnm, key, iter| !model.get_object_column(iter).text_match?(key) }

		on_no_selection			# Starts with no selection...
		self.title = title
	end

	def show_for(objects)
		present
	end

	###################################################################
	# Block Callbacks
	###################################################################
	callback :add

	attr_reader :selected_class

private

	def on_selection(klass)
		@selected_class = klass
		@name_label.markup = sprintf(TITLE_MARKUP_FORMAT, klass.title || DEFAULT_TITLE)

		description = klass.description
		description = DEFAULT_DESCRIPTION if (description.nil? or description.empty?)

		description += "\n\n<i>Hint: #{klass.hint}</i>" if ($settings['enable-hints'] && !klass.hint.empty?)

		# Editor setting for showing summarized settings?
		#description += "\n\n" + klass.settings.collect { |s| "#{s.name} <b><small>(#{s.klass})</small></b>" }.join("\n")

		@description_label.markup = sprintf(DESCRIPTION_MARKUP_FORMAT, description)
	end

	def on_no_selection
		@name_label.markup = sprintf(TITLE_MARKUP_FORMAT, EMPTY_TITLE)
		@description_label.markup = sprintf(DESCRIPTION_MARKUP_FORMAT, EMPTY_DESCRIPTION)
	end

	def send_selected
		add_notify(@selected_class)
	end

	###################################################################
	# GTK Callbacks
	###################################################################
	def on_ok_button_clicked
		hide
		send_selected
	end

	def on_edit_source_button_clicked
		@class_treeview.selected_each { |klass|
			open("|#{EditorWindow::SOURCE_EDITOR_EXECUTABLE_NAME} \"#{klass.source_file_path}\"")
		}
	end
end
