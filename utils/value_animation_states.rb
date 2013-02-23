module ValueAnimationStates
	def animation_states
		@animation_states ||= {}
	end

	def set_state(name, options)
		add_state(name, options)
		@value_animation_state = name
		set(options)
	end

	def add_state(name, options)
		animation_states[name] = options
		self
	end

	def has_state?(name)
		!animation_states[name].nil?
	end

	def animate_to_state(name, duration=0.5, &proc)
		options = animation_states[name]
		raise ArgumentError unless options
		@value_animation_state = name		# BEFORE animation makes it official
		animate(options, duration) {
			proc.call if proc
		}
		self
	end

	# transitions like {:old => :new, :other => :fourth}
	def switch_state(transitions, duration=0.5, &proc)
		if (new_state = transitions[@value_animation_state])
			animate_to_state(new_state, duration, &proc)
			true
		else
			false
		end
	end
end
