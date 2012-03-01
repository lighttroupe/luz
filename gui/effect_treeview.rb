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

require 'child_treeview'

class EffectTreeView < ChildTreeView
	column :uses_enter_pixbuf, :renderers => [{:name => :uses_enter_pixbuf, :type => :pixbuf, :model_column => :uses_enter_pixbuf, :options => {}}], :expand => false, :position => 1
	column :uses_exit_pixbuf, :renderers => [{:name => :uses_exit_pixbuf, :type => :pixbuf, :model_column => :uses_exit_pixbuf, :options => {}}], :expand => false, :position => 2
end
