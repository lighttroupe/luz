multi_require 'parent_user_object', 'taggable', 'style'

class Theme < ParentUserObject
	title 'Theme'

	include Taggable

	def to_yaml_properties
		tag_instance_variables + super
	end

	setting 'background_color', :color, :default => [0.0,0.0,0.0,1.0], :only_literal => true

	def default_title
		'New Theme'
	end

	def after_load
		#set_default_instance_variables(:titile => '')
		super
		after_load_tag_class_registration
	end

	def before_delete
		clear_tags
		super
	end

	def empty?
		effects.empty?
	end

	def style(index)
		effects[index % effects.size]
	end

	def using_style(index)
		return yield if effects.empty?
		style(index).using { yield }
	end

	def using_style_amount(index, amount)
		return yield if (amount == 0.0 or effects.empty?)
		effects[index % effects.size].using_amount(amount) { yield }
	end
end
