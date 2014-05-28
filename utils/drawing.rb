# Mixin: Drawing.
#
#  class MyClass
#    include Drawing
#    ...
#  end

module Drawing
	def self.included(base) #:nodoc:
		base.extend(ClassMethods)
	end

	###################################################################
	#
	# Class-level methods
	#
	###################################################################

	module ClassMethods
	end

#	def self.conditional(*methods)
#		methods.each { |method|
#			self.class_eval <<-end_class_eval
#				def #{method}_if(bool, *args, &proc)
#					if bool
#						#{method}(*args, &proc)
#					else
#						yield
#					end
#				end
#			end_class_eval
#		}
#	end

	###################################################################
	#
	# Mix-ins
	#
	###################################################################

	# Fuzzy Math
	require 'drawing/drawing_fuzzy_math'
	include DrawingFuzzyMath

	# Screen
	require 'drawing/drawing_screen'
	include DrawingScreen

	# Color
	require 'drawing/drawing_color'
	include DrawingColor

	# Texture
	require 'drawing/drawing_texture'
	include DrawingTexture

	# Shapes
	require 'drawing/drawing_shapes'
	include DrawingShapes

	# Lines
	require 'drawing/drawing_lines'
	include DrawingLines

	# Transformations
	require 'drawing/drawing_transformations'
	include DrawingTransformations

	# Clipping
	require 'drawing/drawing_clipping'
	include DrawingClipping

	# Stencil Buffer
	require 'drawing/drawing_stencil_buffer'
	include DrawingStencilBuffer

	# FrameBuffer Objects
	require 'drawing/drawing_frame_buffer_objects'
	include DrawingFrameBufferObjects

	# Shader Snippets
	require 'drawing/drawing_shader_snippets'
	include DrawingShaderSnippets

	# Frame Saving
	require 'drawing/drawing_frame_saving'
	include DrawingFrameSaving

	# Hit Testing
	require 'drawing/drawing_hit_testing'
	include DrawingHitTesting
end
