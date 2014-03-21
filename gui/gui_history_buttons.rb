class GuiHistoryButton < GuiButton
	def initialize(history)
		@history = history
	end
end

class GuiBackButton < GuiHistoryButton
	def click(pointer)
		@history.back!
	end

	def gui_render!
		with_alpha(@history.can_go_back? ? 1.0 : 0.2) {
			super
		}
	end
end

class GuiForwardButton < GuiHistoryButton
	def click(pointer)
		@history.forward!
	end

	def gui_render!
		with_alpha(@history.can_go_forward? ? 1.0 : 0.2) {
			super
		}
	end
end
