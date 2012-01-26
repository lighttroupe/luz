 ###############################################################################
 #  Copyright 2011 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

# Mixin: Drawing.
#
# A typical and safe use is as follows:
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
	require 'drawing_fuzzy_math'
	include DrawingFuzzyMath

	# Screen
	require 'drawing_screen'
	include DrawingScreen

	# Color
	require 'drawing_color'
	include DrawingColor

	# Texture
	require 'drawing_texture'
	include DrawingTexture

	# Shapes
	require 'drawing_shapes'
	include DrawingShapes

	# Lines
	require 'drawing_lines'
	include DrawingLines

	# Transformations
	require 'drawing_transformations'
	include DrawingTransformations

	# Clipping
	require 'drawing_clipping'
	include DrawingClipping

	# Stencil Buffer
	require 'drawing_stencil_buffer'
	include DrawingStencilBuffer

	# Framebuffer Objects
	require 'drawing_framebuffer_objects'
	include DrawingFramebufferObjects

	# Shader Snippets
	require 'drawing_shader_snippets'
	include DrawingShaderSnippets

	# Frame Saving
	require 'drawing_frame_saving'
	include DrawingFrameSaving

	# Hit Testing
	require 'drawing_hit_testing'
	include DrawingHitTesting
end
