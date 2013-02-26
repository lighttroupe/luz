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

class ParentUserObjectListStore < UserObjectListStore
	column :title_and_tags, :type => :text, :from_object => Proc.new { |object|
		string = object.title.pango_escaped.with_optional_pango_tag(object.crashy?, 'i')

		# Settings Summary
		settings_summary_string = object.settings_summary.join(', ')
		string += sprintf("\n<small><small><span color='lightblue'><b>  (%s)</b></span></small></small>", settings_summary_string) if (settings_summary_string and !settings_summary_string.empty?)

		# Tags
		string += "\n  <small><small>tags #{object.tags.sort.collect { |t| t.with_pango_tag('u') }.join(', ') }</small></small>" if (object.respond_to? :tags and !object.tags.empty?)

		string
	}
end
