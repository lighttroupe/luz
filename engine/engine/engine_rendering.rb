module EngineRendering
	def render(enable_frame_saving)
		$gui.render {
			if enable_frame_saving && frame_saving_requested?
				render_with_frame_saving
			else
				render_without_frame_saving
			end
		}
	end

	def with_content_aspect_ratio
		with_scale(0.62, 1.0) {			# TODO: proper numbers
			yield
		}
	end

	def render_with_frame_saving
		with_frame_saving { |target_buffer|
			target_buffer.using(:clear => true) {
				with_content_aspect_ratio {		# TODO: properly set aspect ratio
					render_without_frame_saving
				}
			}
			# draw created image to screen
			target_buffer.with_image {
				fullscreen_rectangle
			}
		}
	end

	def render_without_frame_saving
		render_recursively(@project.effects) { }
	end

	#
	# NOTE: This is a prototype for a generic recursive renderer, to replace that of actors/directors and maybe themes/variables/events
	#
	def render_recursively(user_objects, index=0, &proc)
		uo = user_objects[index]
		return proc.call unless uo

		if uo.usable?
			$engine.user_object_try(uo) {
				uo.resolve_settings
				uo.tick!
				uo.render {
					render_recursively(user_objects, index+1, &proc)		# continue (potentially multiple times-- this is how Grid and other child-creating plugins work)
				}
			}
		else
			render_recursively(user_objects, index+1, &proc)				# skip
		end
	end

	#
	# OpenGL
	#
	def set_opengl_projection
		@camera_distance_from_origin = 0.5

		# TODO: comment formula below
		angle = 2.0 * Math.atan(0.5 / @camera_distance_from_origin) * RADIANS_TO_DEGREES

		GL.MatrixMode(GL::PROJECTION)
		GL.LoadIdentity

		GLU.Perspective(angle, 1.0, 0.001, 1024.0)		# 1.0 is output ratio. NOTE: near/far clip plane numbers are somewhat arbitrary.
	end

	def set_opengl_view
		GL.MatrixMode(GL::MODELVIEW)
		GL.LoadIdentity
		GL.Translate(0,0,-@camera_distance_from_origin) # NOTE: makes a 1x1 object at the origin visible/fullscreen
	end

	def set_opengl_defaults
		GL.Enable(GL::BLEND)
		GL.BlendFunc(GL::SRC_ALPHA, GL::ONE_MINUS_SRC_ALPHA)

		# POLYGON_SMOOTH causes seams on NVidia hardware
		#GL.Enable(GL::POLYGON_SMOOTH)
		#GL.Hint(GL::POLYGON_SMOOTH_HINT, GL::NICEST)

		GL.ShadeModel(GL::FLAT)			# TODO: probably want to change this

		# When using painter's algorithm for 2D, no need for depth test
		GL.Disable(GL::DEPTH_TEST)

		# Many effects rely on the backface to be visible (eg. flip_horizontally)
		GL.Disable(GL::CULL_FACE)
		GL.PolygonMode(GL::FRONT, GL::FILL)
		GL.PolygonMode(GL::BACK, GL::FILL)

		GL.Enable(GL::TEXTURE_2D)
	end
end
