require 'user_object_setting'

class UserObjectSettingThemes < UserObjectSetting
	def to_yaml_properties
		super		# TODO
	end

	def after_load
		# TODO set_default_instance_variables(...)
		super
	end

	#
	# API for plugins
	#
	def one(index=0)
		list = get_themes
		yield list[index % list.size] unless list.empty?		# NOTE: wraps around to 0, is this the right behavior?
	end

	def count
		get_themes.size
	end

	def each
		get_themes.each { |theme| yield theme }
	end

	def all
		yield get_themes
	end

private

	def get_themes
		$engine.project.themes
	end
end
