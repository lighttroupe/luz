class GuiDirectorView < GuiBox
	attr_accessor :director

	def gui_render
		if false
			camera.using {
				scaffolding.render
				@director.render if @director
			}
		else
			@director.render! if @director
		end
	end

	#
	# Scrollwheel behavior
	#
	SCROLL_AMOUNT = 0.1
	def scroll_up!(pointer)
		if pointer.hold?
			camera.move_up(SCROLL_AMOUNT)
		else
			camera.move_forward(SCROLL_AMOUNT)
		end
	end
	def scroll_down!(pointer)
		if pointer.hold?
			camera.move_up(-SCROLL_AMOUNT)
		else
			camera.move_forward(-SCROLL_AMOUNT)
		end
	end
	def scroll_left!(pointer)
		camera.move_left(SCROLL_AMOUNT)
	end
	def scroll_right!(pointer)
		camera.move_left(-SCROLL_AMOUNT)
	end

private

	def camera
		@camera ||= GLCamera.new
	end

	def scaffolding
		@scaffolding ||= CartesianScaffolding.new
	end
end
