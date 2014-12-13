require 'user_object_setting'

class UserObjectSettingActor < UserObjectSetting
	include Drawing

	HANDLE_POSITION = 1
	GRAB_DISTANCE = 5

	attr_accessor :x, :y, :z

	def to_yaml_properties
		super + ['@actor', '@x', '@y', '@z']
	end

	def after_load
		set_default_instance_variables(:x => 0.0, :y => 0.0, :z => 0.0)
		super
	end

	def draw_hit_test_handles
		GL.PointSize(GRAB_DISTANCE * 4)

		with_unique_hit_test_color_for_object(self, user_data=HANDLE_POSITION) {
			GL.Begin(GL::POINTS) ; GL.Vertex(0.0, 0.0, 0.0) ; GL.End
		}
	end

	def draw_handles
		GL.PushAll {
			GL.LineWidth(4.0)

			GL.PointSize(GRAB_DISTANCE * 2)		# NOTE: OpenGL point sizes aren't affected by scaling
			GL.Color(0.0, 0.0, 0.0, 0.7)
			unit_square_outline

			GL.Begin(GL::POINTS)
				GL.Vertex( 0.0,  0.0, 0.0)
			GL.End

			GL.LineWidth(2.0)
			GL.PointSize((GRAB_DISTANCE * 2) - 2)
			GL.Color(1.0, 1.0, 1.0, 0.7)
			unit_square_outline
			GL.Begin(GL::POINTS)
				GL.Vertex( 0.0,  0.0, 0.0)
			GL.End
		}
	end

	def with_scaffolding
		with_translation(@x, @y, @z) {
			if $env[:hit_test]
				draw_hit_test_handles
			else
				yield
				draw_handles if $env[:draw_handles]
			end
		}
	end

	#
	# API for plugins
	#
	def present?
		!@actor.nil?
	end

	def one
		with_scaffolding { yield @actor } if @actor
	end

	# TODO: remove one of these
	def render
		with_scaffolding { @actor.render! } if @actor
	end

	def render!
		with_scaffolding { @actor.render! } if @actor
	end

	def summary
		summary_format(@actor.title) if @actor
	end
end
