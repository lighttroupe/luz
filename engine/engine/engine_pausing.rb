module EnginePausing
	boolean_accessor :paused

	def paused=(pause)
		project.effects.each { |effect| effect.pause if effect.respond_to? :pause } if pause and !@paused
		@paused = pause
	end
end
