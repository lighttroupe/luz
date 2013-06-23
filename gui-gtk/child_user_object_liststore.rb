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

require 'user_object_liststore'

$uses_enter_pixbuf_on ||= Gdk::Pixbuf.new("gui-gtk/icons/uses-enter-on.png")
$uses_enter_pixbuf_off ||= Gdk::Pixbuf.new("gui-gtk/icons/uses-enter-off.png")

$uses_exit_pixbuf_on ||= Gdk::Pixbuf.new("gui-gtk/icons/uses-exit-on.png")
$uses_exit_pixbuf_off ||= Gdk::Pixbuf.new("gui-gtk/icons/uses-exit-off.png")

class ChildUserObjectListStore < UserObjectListStore
	column :title, :type => :text, :from_object => Proc.new { |object|
		string = object.title.pango_escaped.with_optional_pango_tag(object.crashy?, 'i')

		settings_summary_string = object.settings_summary.join(', ')
		string += sprintf("\n<small><small><span color='lightblue'><b>  (%s)</b></span></small></small>", settings_summary_string) if (settings_summary_string and !settings_summary_string.empty?)

		if object.respond_to? :conditions
			conditions_string = object.conditions.summary_in_pango_markup
			string += sprintf("\n<small><small><span color='yellow'><b>%s</b></span></small></small>", conditions_string) if (conditions_string and !conditions_string.empty?)
		end

		string
	}

	column :uses_enter_pixbuf, :type => :pixbuf, :from_object => Proc.new { |object| (object.settings.find { |setting| setting.uses_enter? }) ? $uses_enter_pixbuf_on : $uses_enter_pixbuf_off }
	column :uses_exit_pixbuf, :type => :pixbuf, :from_object => Proc.new { |object| (object.settings.find { |setting| setting.uses_exit? }) ? $uses_exit_pixbuf_on : $uses_exit_pixbuf_off }
end
