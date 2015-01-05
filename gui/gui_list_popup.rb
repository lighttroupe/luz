class GuiListPopup < GuiBox
	easy_accessor :item_aspect_ratio

	pipe :get_value, :list
	pipe :set_value, :list

	callback :selected

	def initialize(pointer)
		super()
		@pointer = pointer
		create!
	end

	def includes_gui_object?(object)
		
	end

	def set_objects(objects)
		@objects = objects

		@objects.each { |object|
			object.on_clicked {
				@objects.each { |o2| o2.animate(:opacity => 0.2) unless object == o2 }		# FX: all but the selected item disappears
				selected_notify(object)
				exit!
			}
		}

		unless @list
			# HACK to build the list once we have item_aspect_ratio available (after new.set)
			self << (@list = (GuiList.new(@objects).set(:scale_x => 0.85, :scale_y => 0.7, :scroll_wrap => true, :spacing_y => -1.0, :item_aspect_ratio => item_aspect_ratio)))
		end

		# Pointer takes responsibility for this window, and it auto-closes when pointer clicks away
		@pointer.capture_object!(self) { |click_object|		# callback is for a click
			if @objects.include?(click_object)
				selected_notify(click_object)
				false		# drop capture, user has selected...
			elsif @contents.include?(click_object)
				true		# user is working with the popup... keep the capture
			else
				@pointer.uncapture_object!
				exit!
				false
			end
		}

		self
	end

private

	def create!
		self << GuiObject.new.set(:background_image => $engine.load_image('images/list-popup-background.png'))
		self << @up_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/scroll-up.png'), :background_image_hover => $engine.load_image('images/buttons/scroll-up-hover.png'),:background_image_click => $engine.load_image('images/buttons/scroll-up-click.png'), :offset_y => 0.4, :scale_y => 0.06)
		self << @down_button = GuiButton.new.set(:background_image => $engine.load_image('images/buttons/scroll-up.png'), :background_image_hover => $engine.load_image('images/buttons/scroll-up-hover.png'),:background_image_click => $engine.load_image('images/buttons/scroll-up-click.png'), :offset_y => -0.4, :scale_y => -0.06)
		#@list.scroll_to(self.get_value)
		@up_button.on_holding { |pointer| @list.scroll_by(pointer, -0.1) }
		@down_button.on_holding { |pointer| @list.scroll_by(pointer, 0.1) }
	end
end
