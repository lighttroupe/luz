multi_require 'cartesian_scaffolding', 'camera'

class GuiDirectorView < GuiBox
	attr_accessor :director

	def gui_render!
		camera.using {
			scaffolding.render
			@director.render if @director
		}
	end

	#
	# Scrollwheel behavior
	#
	def scroll_up!(pointer)
		if pointer.hold?
			camera.move_up(0.1)
		else
			camera.move_forward(0.1)
		end
	end
	def scroll_down!(pointer)
		if pointer.hold?
			camera.move_up(-0.1)
		else
			camera.move_forward(-0.1)
		end
	end
	def scroll_left!(pointer)
		camera.move_left(0.1)
	end
	def scroll_right!(pointer)
		camera.move_left(-0.1)
	end

private

	def camera
		@camera ||= GLCamera.new
	end

	def scaffolding
		@scaffolding ||= CartesianScaffolding.new
	end
end
