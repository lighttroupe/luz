module EnginePausing
	boolean_accessor :paused

	def init_pausing
		@paused = false
	end

	def paused=(pause)
		project.effects.each { |effect| effect.pause if effect.respond_to? :pause } if pause && !@paused
		@paused = pause
	end
end
