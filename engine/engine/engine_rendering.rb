module EngineRendering
	SCREEN_BACKGROUND_COLOR = [0,0,0,0]

	def tick(frame_time)
		slider_tick								# TODO: does this really need to come first?

		@frame_number += 1				# ; printf("Frame: %05d ==================================\n", @frame_number)

		project_pretick						# NOTE: at this point $env is from previous frame
		update_time(frame_time)
		read_from_message_bus
		update_environment
		resolve_events
		project_tick
		update_beats(frame_time)

		$gui.gui_tick! if $gui

		@last_frame_time = frame_time
	end

	def render(enable_frame_saving)
		clear_screen(SCREEN_BACKGROUND_COLOR)
		$gui.render {
			if enable_frame_saving && frame_saving_requested?
				render_with_frame_saving
			else
				render_without_frame_saving
			end
		}
	end

	def render_with_frame_saving
		with_frame_saving { |target_buffer|
			target_buffer.using(:clear => true) {
				render_without_frame_saving
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
	def projection
		@camera_distance_from_origin = 0.5

		# TODO: comment formula below
		angle = 2.0 * Math.atan(0.5 / @camera_distance_from_origin) * RADIANS_TO_DEGREES

		GL.MatrixMode(GL::PROJECTION)
		GL.LoadIdentity

		# 1.0 = output ratio
		GLU.Perspective(angle, 1.0, 0.001, 1024.0) # NOTE: near/far clip plane numbers are somewhat arbitrary.
	end

	def view
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
