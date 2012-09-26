require 'drawing'

class FramebufferObject
	include Drawing

	attr_reader :image, :height, :width

	def initialize(settings={})
		@width, @height = (settings[:width] || 1024), (settings[:height] || 768)		# TODO: use screen resolution
		@clear_color = [0.0, 0.0, 0.0, 0.0]
		create
	end

private

	def create
		@fbo = GL.GenFramebuffersEXT(1).first

		# Bind it
		GL.BindFramebufferEXT(GL::FRAMEBUFFER_EXT, @fbo)

		#GL.RenderbufferStorageEXT(GL::RENDERBUFFER_EXT, GL::RGBA, @width, @height)

		# create texture to render into
		@image = GL.GenTexture
		GL.BindTexture(GL::TEXTURE_2D, @image)

		#
		# GL_CLAMP, GL_CLAMP_TO_BORDER, GL_CLAMP_TO_EDGE, GL_MIRRORED_REPEAT, or GL_REPEAT (default)
		# (MIRRORED_REPEAT flips a basic Image of Previous Frame vertically)
		#
		GL.TexParameter(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT)		# REPEAT mode adds noise to the transparent edge of a texture opposite an opaque edge
		GL.TexParameter(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT)

		GL.TexParameter(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR) # or GL::NEAREST
		GL.TexParameter(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR) # or GL::NEAREST

		GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGBA8, @width, @height, 0, GL::RGBA, GL::UNSIGNED_BYTE, nil)

		# attach texture to FBO
		GL.FramebufferTexture2DEXT(GL::FRAMEBUFFER_EXT, GL::COLOR_ATTACHMENT0_EXT, GL::TEXTURE_2D, @image, 0)

		#
		# Depth buffer
		#
		#@depth_buffer = GL.GenRenderbuffersEXT(1).first
		#GL.BindRenderbufferEXT(GL::RENDERBUFFER_EXT, @depth_buffer)
		#GL.RenderbufferStorageEXT(GL::RENDERBUFFER_EXT, GL::DEPTH_COMPONENT, @width, @height)
		#GL.BindRenderbufferEXT(GL::RENDERBUFFER_EXT, 0)
		#GL.FramebufferRenderbufferEXT(GL::FRAMEBUFFER_EXT, GL::DEPTH_ATTACHMENT_EXT, GL::RENDERBUFFER_EXT, @depth_buffer)

		# check status
		if (status = GL.CheckFramebufferStatusEXT(GL::FRAMEBUFFER_EXT)) != GL::FRAMEBUFFER_COMPLETE_EXT
			puts "framebuffer creation failed (status: #{status})"
		end
		GL.BindFramebufferEXT(GL::FRAMEBUFFER_EXT, 0)
	end

public

	$fbo_stack ||= []
	def using(options={})
		$fbo_stack << @fbo

		# Switch rendering to FBO
		GL.BindFramebufferEXT(GL::FRAMEBUFFER_EXT, @fbo)

		GL.PushAttrib(GL::VIEWPORT_BIT)
		GL.Viewport(0, 0, @width, @height)

		with_identity_transformation {
			clear_screen(@clear_color) unless options[:clear] === false
			yield
		}

		GL.PopAttrib
		$fbo_stack.pop
		GL.BindFramebufferEXT(GL::FRAMEBUFFER_EXT, $fbo_stack.last || 0)
	end

	def with_image(&proc)
		with_texture_scale(1.0, -1.0) {		# texture coordinates seem to need to be flipped vertically with FBOs
			with_texture(@image, &proc)
		}
	end
end
