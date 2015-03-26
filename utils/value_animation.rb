#
# ValueAnimation animates objects' instance variables over time, with optional callback at the end.
#
# a Ruby version of jQuery's animate()
#
multi_require 'struct_stack'

class ValueAnimationManager < Array
	Animation = Struct.new(:object, :get_method, :set_method, :begin_value, :end_value, :begin_time, :end_time, :proc)

	def initialize
		super
		@animation_struct_stack ||= StructStack.new(Animation)
	end

	def add_animation(object, field, target_value, duration, &proc)
		set_method = (field.to_s+'=').to_sym
		current_value = object.send(field)

		# TODO: if current_value == target_value ... call proc and return?

		# HACK: coerce start value (until we have default values for all settings)
		current_value ||= 0.0 if target_value.is_a? Float

		finalize_animations_for_object_and_field!(object, field)

		# HACK: until we have some other way to do it, we'll need to turn hidden=false before anything else, otherwise the animation is invisible
		# of course this level shouldn't know what :hidden means...
		object.send(set_method, target_value) if field == :hidden && target_value == false

		self << @animation_struct_stack.pop(object, field, set_method, current_value, target_value, (frame_time=$env[:frame_time]), (frame_time + duration), proc)
	end

	def tick_animations!
		delete_if { |animation|
			progress = ($env[:frame_time] - animation.begin_time) / (animation.end_time - animation.begin_time)
			if progress >= 1.0
				finalize_animation!(animation)
				true		# delete
			else
				if animation.end_value.is_a? Float
					current_value = progress.scale(animation.begin_value, animation.end_value)
					animation.object.send(animation.set_method, current_value)
				else
					# no animation for boolean, or others (just set their final value above)
				end
				false		# keep
			end
		}
	end

	def finalize_animations_for_object_and_field!(object, field)
		delete_if { |animation|
			if animation.object == object && animation.get_method == field
				finalize_animation!(animation)
				true		# delete
			else
				false		# keep
			end
		}
	end

	def finalize_animation!(animation)
		animation.object.send(animation.set_method, animation.end_value)
		animation.proc.call(animation.object) if animation.proc		# callback
		@animation_struct_stack.push(animation)				# recycle
	end
end

$value_animation_manager ||= ValueAnimationManager.new

module ValueAnimation
	def animate(fields, target_value=:none, duration=0.5, &proc)
		if fields.is_a? Hash
			# eg animate({:opacity => 1.0})
			duration = target_value unless target_value == :none
			fields.each { |field, target_value|
				add_animation(field, target_value, duration, &proc)
				proc = nil		# only the first one should call the proc
			}
		else
			# eg animate(:opacity, 1.0)
			field = fields
			add_animation(field, target_value, duration, &proc)
		end
		self
	end

	# Add a single value animation
	def add_animation(field, target_value, duration, &proc)
		$value_animation_manager.add_animation(self, field, target_value, duration, &proc)
	end
end 
