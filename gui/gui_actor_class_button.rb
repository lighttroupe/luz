class GuiActorClassButton < GuiClassInstanceRendererButton
	def with_hover_effect
		with_roll(-0.01 + fuzzy_sine($env[:beat]) * 0.02) {
			yield
		}
	end
end
