#
# History implements a basic browser-like forward/backward history with change notification.
#
require 'callbacks'

class History
	callback :navigation

	def initialize
		@list = []
		@index = -1
	end

	#
	# Status
	#
	def can_go_back?
		@index > 0
	end

	def current?
		@index > -1
	end

	def current
		@list[@index] if current?
	end

	def can_go_forward?
		@index < (@list.size - 1)
	end

	#
	# Navigation
	#
	def back!
		if can_go_back?
			@index -= 1
			navigation_notify(current)
			true
		end
	end

	def forward!
		if can_go_forward?
			@index += 1
			navigation_notify(current)
			true
		end
	end

	#
	# Manipulation
	#
	def add(item)
		@index += 1
		@list[@index] = item
		@list = @list.first(@index+1)		# chop off all history after this index
	end

	def remove(item)
		return unless (index = @list.index(item))
		@index -= 1 if index <= @index
		@list.delete(item)
	end
end
