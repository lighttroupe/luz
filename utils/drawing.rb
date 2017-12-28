#
# OpenGL Abstraction layer
#
module Drawing
	def self.included(base) #:nodoc:
		base.extend(ClassMethods)
	end

	# Fuzzy Math
	multi_require 'drawing/drawing_fuzzy_math'
	include DrawingFuzzyMath

	# Screen
	multi_require 'drawing/drawing_screen'
	include DrawingScreen

	# Color
	multi_require 'drawing/drawing_color'
	include DrawingColor

	# Texture
	multi_require 'drawing/drawing_texture'
	include DrawingTexture

	# Shapes
	multi_require 'drawing/drawing_shapes'
	include DrawingShapes

	# Lines
	multi_require 'drawing/drawing_lines'
	include DrawingLines

	# Transformations
	multi_require 'drawing/drawing_transformations'
	include DrawingTransformations

	# Clipping
	multi_require 'drawing/drawing_clipping'
	include DrawingClipping

	# Stencil Buffer
	multi_require 'drawing/drawing_stencil_buffer'
	include DrawingStencilBuffer

	# FrameBuffer Objects
	multi_require 'drawing/drawing_frame_buffer_objects'
	include DrawingFrameBufferObjects

	# Shader Snippets
	multi_require 'drawing/drawing_shader_snippets'
	include DrawingShaderSnippets

	# Frame Saving
	multi_require 'drawing/drawing_frame_saving'
	include DrawingFrameSaving

	# Hit Testing
	multi_require 'drawing/drawing_hit_testing'
	include DrawingHitTesting
end
