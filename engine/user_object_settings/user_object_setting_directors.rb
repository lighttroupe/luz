require 'user_object_setting'

class UserObjectSettingDirectors < UserObjectSetting
	#
	# API for plugins
	#
	def one(index=0)
		list = get_directors
		return if list.empty?		# NOTE: doesn't yield

		selection = list[index % list.size]		# NOTE: wraps at both edges
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
