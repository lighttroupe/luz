class ProjectEffectScreenClear < ProjectEffect
	title				'Screen Clear'
	description "Clears screen (frame buffer) to selected color."

	setting 'color', :color, :default => [0.0,0.0,0.0]
	setting 'amount', :float, :range => 0.0..1.0, :default => 1.0..0.0

	def render
		fade_screen_to_color_with_alpha_blend(color, amount)
		yield
	end
end
