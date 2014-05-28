require 'user_object_setting'

# Actor factory
# -> Sometimes you want one
# -> Sometimes you want one by tag (by index)
# -> Sometimes you want all by tag

class UserObjectSettingActors < UserObjectSetting
	def to_yaml_properties
		super + ['@tag']
	end

	def after_load
		set_default_instance_variables(:tag => nil)
		super
	end

	#
	# API for plugins
	#
	def one(index=0)
		list = Actor.with_tag(@tag)
		return nil if list.empty?		# NOTE: return without yielding

		selection = list[index % list.size]		# NOTE: nicely wraps around at both edges
		yield selection if block_given?
		selection
	end

	def count
		Actor.with_tag(@tag).size
	end

	def each
		Actor.with_tag(@tag).each { |actor| yield actor }
	end

	def each_with_index
		Actor.with_tag(@tag).each_with_index { |actor, index| yield actor, index }
	end

	def all
		yield Actor.with_tag(@tag)
	end
end
