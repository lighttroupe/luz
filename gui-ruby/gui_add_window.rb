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
		# Background
		self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/add-window-background.png')))

		@category = @categories.first

		#
		# Category selector
		#
		self << (@category_selector = GuiRadioButtons.new(self, :category, categories_for_radio_buttons).set(:offset_x => 0.005, :offset_y => 0.44, :scale_x => 0.16 * @categories.size, :scale_y => 0.11, :spacing_x => 1.0))
		@category_selector.on_selection_change {
			fill_from_category!
		}

		#
		# Effects list and scrollbar
		#
		self << (@list = GuiListWithControls.new.set({:offset_x => -0.33, :offset_y => -0.07, :scale_x => 0.33, :scale_y => 0.865, :spacing_y => -0.8, :item_aspect_ratio => 4.0}))
		self << (@list_scrollbar = GuiScrollbar.new(@list).set({:offset_x => -0.154, :offset_y => -0.07, :scale_x => 0.025, :scale_y => 0.865}))

		self << (@title = BitmapFont.new.set({:string => '', :offset_x => 0.19, :offset_y => 0.3, :scale_x => 0.58, :scale_y => 0.1}))
		self << (@hint = BitmapFont.new.set({:string => '', :color => [0.7,0.7,0.7], :offset_x => 0.19, :offset_y => 0.2, :scale_x => 0.58, :scale_y => 0.06}))

		self << (@hint = BitmapFont.new.set({:string => '', :color => [0.7,0.7,0.7], :offset_x => 0.19, :offset_y => 0.2, :scale_x => 0.58, :scale_y => 0.06}))

		#
		# Close
		#
		self << (@close_button=GuiButton.new.set(:scale_x => 0.08, :scale_y => 0.15, :offset_x => 0.46, :offset_y => 0.43, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked { hide! }

		fill_from_category!
	end

	def fill_from_category!
		puts "fill_from_category! #{@category}"

		@list.clear!
		@title.set_string('')
		@hint.set_string('')

		find_valid_effect_classes.each { |object|
			next unless (@category.nil? || object.in_category?(@category))

			# wrap in a renderer
			renderer = GuiObjectRenderer.new(object)

			# user selects an effect (class)
			renderer.on_clicked {
				select_object(object)
			}

			@list << renderer
		}
	end

	def select_object(object)
		if object == @selected_object
			add_object(object)
			hide!
		else
			@selected_object = object
			create_for_object(@selected_object)
		end
	end

	def create_for_object(object)
		@title.set_string(object.title)
		@hint.set_string(object.hint)
	end

	def add_object(object)
		new_object = object.new
		new_object.after_load
		add_notify(new_object)
	end

	def hide!
		animate({:opacity => 0.0, :offset_y => offset_y - 0.1, :scale_x => scale_x * 1.1}, duration=0.1) { set_hidden(true) }
	end

	def find_valid_effect_classes
		UserObject.inherited_classes.select { |user_object_class|
			@user_object.valid_child_class?(user_object_class) && !user_object_class.virtual? && !user_object_class.title.blank?
		}.sort { |a,b| a.title <=> b.title }
	end

	def categories_for_radio_buttons
		@categories.map { |category| [category, $engine.load_image(category_image_path(category))] }
	end

	def category_image_path(category)
		"images/categories/#{category}.png"
	end
end
