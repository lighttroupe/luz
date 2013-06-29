class GuiActorsFlyout < GuiBox
	def initialize
		super
		create!
	end

	def create!
		# Background
		self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/actor-flyout-background.png')))

		# View directors button
		self << @director_view_button = GuiButton.new.set(:offset_y => 0.5 - 0.025, :scale_y => 0.05, :background_image => $engine.load_image('images/buttons/director-view.png'))
		@director_view_button.on_clicked {
			$gui.build_editor_for($gui.chosen_director)
		}

		# Actor list				# TODO: item_aspect_ratio is related to screen ratio
		self << @actors_list = GuiList.new([]).set(:scroll_wrap => true, :scale_x => 0.91, :scale_y => 0.82, :offset_x => 0.036, :offset_y => 0.0, :spacing_y => -1.0, :item_aspect_ratio => 0.75)

		# New actor button
		self << @new_button = GuiButton.new.set(:offset_y => -0.5 + 0.025, :scale_y => 0.05, :color => [1,1,1])
		@new_button.on_clicked { |pointer|
			klass = ActorStarFlower
			@actors_list.add_after_selection(actor = klass.new)
			$gui.build_editor_for(actor, :pointer => pointer)
		}

		#
		# Actor drawer
		#
=begin
		self << @actor_drawer = GuiVBox.new.set(:scale_x => 0.95, :scale_y => 0.95)

		# New Actor button(s)
		[ActorStarFlower, ActorStar, ActorRectangle].each { |klass|
			@actor_drawer << (new_actor_button = GuiActorClassButton.new(klass).set(:scale => 0.75))
			new_actor_button.on_clicked { |pointer|
				@actors_list.add_after_selection(actor = klass.new)
				index = @actors_list.index(actor)
				build_editor_for(actor, :pointer => pointer)
			}
		}
=end
	end

	def actors=(actors)
		@actors_list.contents = actors
	end

	def remove(actor)
		@actors_list.remove(actor)
	end
end
