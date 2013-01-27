class GuiAddWindow < GuiBox
	easy_accessor :pointer

	def initialize(user_object, options={})
		@user_object, @options = user_object, options
		super([])
		create!
		set(options)
	end

	def create!
		# background
		self << (@background=GuiObject.new.set(:color => [0,0,0,1.0]))

		valid_plugins = find_valid_effect_classes.map { |object|
			renderer = GuiObjectRenderer.new(object)
			renderer.on_clicked {
				@user_object.effects << object.new
				animate({:opacity => 0.0, :offset_y => offset_y - 0.1, :scale_x => scale_x * 1.1}, duration=0.1) { set_hidden(true) }
			}
			renderer
		}

		self << (@list = GuiListWithControls.new(valid_plugins).set({:spacing_y => -0.8, :scale_x => 0.29, :offset_x => -0.35, :scale_y => 0.87, :offset_y => -0.06, :item_aspect_ratio => 3.0}))

		self << (@close_button=GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.15, :offset_x => 0.5, :offset_y => 0.5, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked {
			animate({:opacity => 0.0, :offset_y => offset_y - 0.1, :scale_x => scale_x * 1.1}, duration=0.2) { set_hidden(true) }
		}
	end

	def find_valid_effect_classes
		UserObject.inherited_classes.select { |user_object_class|
			@user_object.valid_child_class?(user_object_class) && !user_object_class.virtual? && !user_object_class.title.blank?
		}.sort { |a,b| a.title <=> b.title }
	end
end
