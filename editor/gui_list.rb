class GuiList < GuiBox
	easy_accessor :spacing

	def each_with_positioning
		with_positioning {
			@contents.each_with_index { |gui_object, index|
				with_translation(0.0, index * (-1.0 - (@spacing || 0.0))) {
					yield gui_object
				}
			}
		}
	end

	def gui_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.gui_render! }
	end

	def hit_test_render!
		return if hidden?
		each_with_positioning { |gui_object| gui_object.hit_test_render! }
	end
end
