class GuiDeleteButton < GuiBox
	callback :clicked

	class DeleteButton < GuiButton
		def on_last_pointer_exit
			parent.close_cover		# auto-close
		end

		#def gui_render
			#super
			#if pointer_hovering?
				#unit_square
			#end
		#end
	end

	def initialize(*args)
		super
		create!
	end

	def create!
		self << @button = DeleteButton.new.set(:offset_x => 0.25, :scale_x => 0.5, :opacity => 0.5, :background_image => $engine.load_image('images/buttons/delete.png'), :background_image_hover => $engine.load_image('images/buttons/delete-hover.png'))
		self << @cover = GuiButton.new.set(:scale_x => 0.5, :opacity => 0.5, :background_image => $engine.load_image('images/buttons/delete-cover.png')).
						add_state(:open, :offset_x => -0.25, :skip_hit_test => true).
						set_state(:closed, :offset_x => 0.25, :skip_hit_test => false)

		@button.on_clicked {
			clicked_notify
		}
		@cover.on_clicked {
			@cover.switch_state({:closed => :open}, duration=0.3)
		}
	end

	def close_cover
		@cover.switch_state({:open => :closed}, duration=0.2)
	end
end
