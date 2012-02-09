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

class Path < Array
	def self.generate
		p = Path.new
		yield p
		return p
	end

	def start_at(x,y)
		clear
		line_to(x,y)
		self
	end

	def line_to(x,y)
		self << x
		self << y
		self
	end

	def first
		self[0, 2]
	end

	def last
		self[-2, 2]
	end

	#def [](i)
		#super[i*2, 2]
	#end

	#def each
		#0.upto(size - 2, 2) { |i| yield [self[i], self[i+1]] }
	#end

	#def size
		#super / 2
	#end

	def append_with_callback(num_points)
		0.upto(num_points-1) { |i| line_to(*yield(i)) }
		self
	end

	def arc_to(center_x, center_y, radius_x, radius_y, radians_start, radians_stop, detail)
		radians_step = (radians_stop - radians_start) / detail.to_f
		radians = radians_start
		for i in 0..detail
			self << center_x + (radius_x * Math.cos(radians))
			self << center_y + (radius_y * Math.sin(radians))
			radians += radians_step
		end
		self
	end
end
