class GuiAddWindow < GuiBox
	BACKGROUND_COLOR = [0,0,0,1.0]

	easy_accessor :pointer

	callback :add

	attr_accessor :category

	def initialize(user_object, options={})
		@user_object, @options = user_object, options
		@categories = @user_object.class.respond_to?(:available_categories) ? @user_object.class.available_categories : []
		super(contents=[])		# added in create!
		create!
		set(options)
	end

private

	def create!
		# background
		self << (@background=GuiObject.new.set(:color => BACKGROUND_COLOR))

		@category = @categories.first

		#
		# Category selector
		#
		self << (@category_selector = GuiRadioButtons.new(self, :category, @categories).set(:offset_x => 0.0, :offset_y => 0.485, :scale_x => 1.0, :scale_y => 0.12, :spacing_x => 1.0))
		@category_selector.on_selection_change {
			fill_from_category!
		}

		#
		# Effects list and scrollbar
		#
		self << (@list = GuiListWithControls.new.set({:offset_x => -0.33, :offset_y => -0.05, :scale_x => 0.33, :scale_y => 0.85, :spacing_y => -0.8, :item_aspect_ratio => 4.0}))
		self << (@list_scrollbar = GuiScrollbar.new(@list).set({:offset_x => -0.167, :offset_y => 0.0, :scale_x => 0.025, :scale_y => 0.75}))

		#
		# Close
		#
		self << (@close_button=GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.15, :offset_x => 0.5, :offset_y => 0.5, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked { hide! }

		fill_from_category!
	end

	def fill_from_category!
		puts "fill_from_category! #{@category}"

		@list.clear!

		find_valid_effect_classes.each { |object|
			next unless (@category.nil? || object.in_category?(@category))

			# wrap in a renderer
			renderer = GuiObjectRenderer.new(object)

			# user selects an effect (class)
			renderer.on_clicked {
				new_object = object.new
				new_object.after_load
				add_notify(new_object)
				hide!
			}

			@list << renderer
		}
	end

	def hide!
		animate({:opacity => 0.0, :offset_y => offset_y - 0.1, :scale_x => scale_x * 1.1}, duration=0.1) { set_hidden(true) }
	end

	def find_valid_effect_classes
		UserObject.inherited_classes.select { |user_object_class|
			@user_object.valid_child_class?(user_object_class) && !user_object_class.virtual? && !user_object_class.title.blank?
		}.sort { |a,b| a.title <=> b.title }
	end
end
