require 'user_object_setting'

class UserObjectSettingActors < UserObjectSetting
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
		list = get_actors
		return nil if list.empty?		# NOTE: return without yielding

		selection = list[index % list.size]		# NOTE: nicely wraps around at both edges
		yield selection if block_given?
		selection
	end

	def count
		get_actors.size
	end

	def each
		get_actors.each { |actor| yield actor }
	end

	def each_with_index
		get_actors.each_with_index { |actor, index| yield actor, index }
	end

	def all
		yield get_actors
	end

private

	def get_actors
		$engine.project.actors		# TODO
	end
end
