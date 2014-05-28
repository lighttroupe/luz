require 'gl_frame_buffer_object'

module DrawingFrameBufferObjects
	DEFAULT_FRAMEBUFFER_SIZE = :large
	FRAMEBUFFER_SIZES = {:large => {:width => 1024, :height => 768}, :medium => {:width => 512, :height => 384}, :small => {:width => 256, :height => 192}}

	def get_offscreen_buffer(size = DEFAULT_FRAMEBUFFER_SIZE)
		@fbo_to_size ||= {}			# so we know which stack to return it to
		@fbo_hash ||= {}				# hash[size] => [fbo, fbo, ...]
		@fbo_hash[size] ||= []

		if @fbo_hash[size].empty?
			fbo = GLFrameBufferObject.new(FRAMEBUFFER_SIZES[size])
			@fbo_to_size[fbo] = size		# record size of new framebuffer
			fbo
		else
			@fbo_hash[size].pop
		end
	end

	def return_offscreen_buffer(fbo)
		@fbo_hash[@fbo_to_size[fbo]] << fbo
	end

	def with_offscreen_buffer(size = DEFAULT_FRAMEBUFFER_SIZE)
		fbo = get_offscreen_buffer(size)
		yield fbo
		return_offscreen_buffer(fbo)
	end
end
