require 'user_object_setting'

class UserObjectSettingDirectors < UserObjectSetting
	#
	# API for plugins
	#
	def one(index=0)
		list = get_directors
		return nil if list.empty?		# NOTE: return without yielding

		selection = list[index % list.size]		# NOTE: nicely wraps around at both edges
		yield selection if block_given?
		selection
	end

	def count
		get_directors.size
	end

	def each
		get_directors.each { |director| yield director }
	end

	def all
		yield get_directors
	end

private

	def get_directors
		$engine.project.directors
	end
end
