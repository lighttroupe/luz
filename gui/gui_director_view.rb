multi_require 'cartesian_scaffolding', 'camera'

class GuiDirectorView < GuiBox
	attr_accessor :director

	def gui_render!
		camera.using {
			scaffolding.render
			@director.render if @director
		}
	end

private

	def camera
		@camera ||= GLCamera.new
	end

	def scaffolding
		@scaffolding ||= CartesianScaffolding.new
	end
end
