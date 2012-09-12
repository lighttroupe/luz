class GuiList < GuiBox
	easy_accessor :spacing_x, :spacing_y

	def each_with_positioning
		with_positioning {
			@contents.each_with_index { |gui_object, index|
				with_translation(index * (@spacing_x || 0.0), index * (@spacing_y || 0.0)) {
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
