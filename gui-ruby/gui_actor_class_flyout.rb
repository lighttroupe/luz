class GuiActorClassFlyout < GuiBox
	callback :actor_class_selected

	def initialize
		super
		create!
	end

	def create!
		# Background
		self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/actor-class-flyout-background.png')))

		self << (@list = GuiVBox.new.set(:scale_x => 0.9, :scale_y => 0.8))

		# New Actor buttons
		[ActorStarFlower, ActorStar, ActorRectangle, ActorRoundedRectangle, ActorLine].each { |klass|
			@list << (new_actor_button = GuiActorClassButton.new(klass).set(:scale_x => 0.75, :scale_y => 0.95))
			new_actor_button.on_clicked { |pointer|
				actor_class_selected_notify(pointer, klass)
			}
		}
	end
end
