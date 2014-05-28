require 'user_object_setting'

# Actor factory
# -> Sometimes you want one
# -> Sometimes you want one by tag (by index)
# -> Sometimes you want all by tag

class UserObjectSettingThemes < UserObjectSetting
	def to_yaml_properties
		super + ['@tag']
	end

	#
	# API for plugins
	#
	def one(index=0)
		list = Theme.with_tag(@tag)
		yield list[index % list.size] unless list.empty?		# NOTE: wraps around to 0, is this the right behavior?
	end

	def count
		Theme.with_tag(@tag).size
	end

	def each
		Theme.with_tag(@tag).each { |theme| yield theme }
	end

	def all
		yield Theme.with_tag(@tag)
	end
end
