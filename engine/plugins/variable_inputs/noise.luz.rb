class VariableInputNoise < VariableInput
	title				"Noise"
	description "A different value on every frame."

	categories :special

	setting 'limit', :float, :range => 0.0..1.0, :default => 1.0..0.0

	def value
		rand * limit
	end
end
