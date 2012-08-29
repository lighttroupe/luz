module ValueAnimation
	Animation = Struct.new(:field, :begin_value, :end_value, :begin_time, :end_time)

	def active_animations
		@active_animations ||= []
	end

	def animation_struct_stack
		@animation_struct_stack ||= StructStack.new(Animation)
	end

	def animate(field, target_value, duration=0.5)
		active_animations << animation_struct_stack.pop(field, send(field), target_value, $env[:frame_time], $env[:frame_time] + duration)
	end

	def tick_animations!
		active_animations.delete_if { |animation|
			progress = ($env[:frame_time] - animation.begin_time) / (animation.end_time - animation.begin_time)
			if progress >= 1.0
				send((animation.field.to_s+'=').to_sym, animation.end_value)
				animation_struct_stack.push(animation)		# recycle
				true																			# remove from array
			else
				current_value = progress.scale(animation.begin_value, animation.end_value)
				send(animation.field.to_s+'=', current_value)
				false
			end
		}
	end
end 
