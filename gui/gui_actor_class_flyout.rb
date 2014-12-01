class GuiActorClassFlyout < GuiWindow
	callback :actor_class_selected

	def initialize
		super
		create!
	end

	def create!
		# Background
		self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/actor-class-flyout-background.png')))

		self << (@list = GuiGrid.new.set(:scale_x => 0.9, :scale_y => 0.5, :offset_y => 0.22, :min_columns => 2))

		# New Actor buttons
		[ActorStarFlower, ActorStar, ActorPolygon, ActorLine, ActorRectangle, ActorRoundedRectangle].each { |klass|
			@list << (new_actor_button = GuiActorClassButton.new(klass).set(:scale_x => 0.75, :scale_y => 0.95))
			new_actor_button.on_clicked { |pointer|
				actor_class_selected_notify(pointer, klass)
			}
		}
	end

	def on_key_press(key)
		case key
		when 'up'
			@list.select_previous!
		when 'down'
			@list.select_next!
		when 'return'
			if (class_button = @list.selection.first)
				actor_class_selected_notify(pointer=nil, class_button.klass)
			end
		else
			super
		end
	end
end
