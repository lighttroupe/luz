class ActorOffscreenCanvas < Actor
	title				"Canvas"
	description "A canvas upon which the Actor Render or Actor Pen plugins can draw."

	setting 'pages', :integer, :range => 1..1000, :default => 1..6
	setting 'forward', :event
	setting 'backward', :event
	#setting 'previous_color', :color, :default => [1.0, 1.0, 1.0, 0.2]

	hint 'The drawn image is persistent, unless erased by effects.'

	FBO_USING_OPTIONS = {:clear => false}

	def render
		current_fbo.with_image { unit_square }
	end

	# 'using' is called by the actor_effects that draw on us
	def using
		current_fbo.using(FBO_USING_OPTIONS) {
			yield
		}
	end

private

	def current_fbo
		fbos[page_index]
	end

	def page_index
		(forward.count - backward.count) % pages
	end

	def fbos
		@fbos ||= Hash.new { |hash, key| hash[key] = create_fbo }
	end

	def create_fbo
		GLFrameBufferObject.new(:height => 1024, :width => 1024)
	end
end
