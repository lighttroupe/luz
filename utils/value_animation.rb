module ValueAnimation
	Animation = Struct.new(:get_method, :set_method, :begin_value, :end_value, :begin_time, :end_time, :proc)

	def active_animations
		@active_animations ||= []
	end

	def animation_struct_stack
		@animation_struct_stack ||= StructStack.new(Animation)
	end

	def animate(fields, target_value=:none, duration=0.5, &proc)
		if fields.is_a? Hash
			# eg animate({:opacity => 1.0})
			duration = target_value unless target_value == :none
			fields.each { |field, target_value|
				add_animation(field, target_value, duration, proc)
				proc = nil		# only the first one should call the proc
			}
		else
			# eg animate(:opacity, 1.0)
			field = fields
			add_animation(field, target_value, duration, proc)
		end
		self
	end

	# Add a single value animation
	def add_animation(field, target_value, duration, proc)
		set_method = (field.to_s+'=').to_sym
		current_value = send(field)

		# HACK: until we have some other way to do it, we'll need to turn hidden=false before anything else, otherwise the animation is invisible
		# of course this level shouldn't know what :hidden means...
		send(set_method, target_value) if field == :hidden && target_value == false

		active_animations << animation_struct_stack.pop(field, set_method, current_value, target_value, $env[:frame_time], $env[:frame_time] + duration, proc)
	end

	def tick_animations!
		active_animations.delete_if { |animation|
			progress = ($env[:frame_time] - animation.begin_time) / (animation.end_time - animation.begin_time)
			if progress >= 1.0
				send(animation.set_method, animation.end_value)
				animation.proc.call(self) if animation.proc		# callback
				animation_struct_stack.push(animation)				# recycle
				true																					# remove from array
			else
				if animation.end_value.is_a? Float
					current_value = progress.scale(animation.begin_value, animation.end_value)
					send(animation.set_method, current_value)
				else
					# no animation for boolean, or others (just set their final value above)
				end
				false
			end
		}
	end
end 
