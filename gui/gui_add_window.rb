class GuiAddWindow < GuiBox
	BACKGROUND_COLOR = [0,0,0,1.0]

	easy_accessor :pointer

	callback :add

	attr_accessor :category, :search

	def initialize(user_object, options={})
		@user_object, @options = user_object, options
		@categories = @user_object.class.respond_to?(:available_categories) ? @user_object.class.available_categories : []
		@search = ''
		super(contents=[])		# added in create!
		create!
		add_state(:open,   {:offset_x => 0.0, :offset_y => -0.05, :scale_x => 1.0, :scale_y => 0.9, :opacity => 1.0, :hidden => false})
		set_state(:closed, {:offset_x => 0.0, :offset_y => -0.10, :scale_x => 0.85, :scale_y => 0.9, :opacity => 0.9, :hidden => true})
		set(options)
	end

	def hide!
		switch_state({:open => :closed}, duration=0.1)
		$gui.default_focus!
	end

	def searching?
		@search && @search.length > 0
	end

	def end_search!
		@search_label.set_value('')
		@search_label.switch_state({:open => :closed}, duration=0.1)
		@category_selector.switch_state({:closed => :open}, duration=0.1)
		fill_from_category!
	end

	def on_key_press(key)
		case key
		when 'escape'
			if searching?
				end_search!
			else
				hide!
			end
		when 'up'
			@list.select_previous!
			@list.scroll_to_selection!
		when 'down'
			@list.select_next!
			@list.scroll_to_selection!
		when 'left'
			unless @categories.empty?
				end_search!
				@category = @categories[(@categories.index(@category) - 1) % @categories.size]
				fill_from_category!
			end
		when 'right'
			unless @categories.empty?
				end_search!
				@category = @categories[(@categories.index(@category) + 1) % @categories.size]
				fill_from_category!
			end
		when 'return'
			add_object(@selected_object) if @selected_object
		else
			if key.control?
				super
			elsif key.alt? && key == 'backspace'
				end_search!
			else
				@search_label.on_key_press(key)
				@search = @search.lstrip

				if searching?
					@search_label.switch_state({:closed => :open}, duration=0.1)
					@category_selector.switch_state({:open => :closed}, duration=0.1)
					fill_from_search!
				else
					end_search!
				end
			end
		end
	end

private

	def create!
		# Background
		self << (@background=GuiObject.new.set(:background_image => $engine.load_image('images/add-window-background.png')))

		@category = @categories.first

		#
		# Category selector
		#
		self << (@category_selector = GuiRadioButtons.new(self, :category, categories_for_radio_buttons).set(:offset_x => -0.5 + (0.08 * @categories.size), :offset_y => 0.44, :scale_x => 0.16 * @categories.size, :scale_y => 0.11, :spacing_x => 1.0)).
			add_state(:closed, {:opacity => 0.0, :hidden => true}).
			set_state(:open, {:opacity => 1.0, :hidden => false})
		@category_selector.on_selection_change {
			fill_from_category!
		}

		self << (@search_label = GuiString.new(self, :search).set(:width => 20, :color => [1.0,1.0,0.0], :offset_x => @category_selector.offset_x, :offset_y => @category_selector.offset_y, :scale_x => @category_selector.scale_x, :scale_y => @category_selector.scale_y)).
			add_state(:open, {:opacity => 1.0, :hidden => false}).
			set_state(:closed, {:opacity => 0.0, :hidden => true})

		#
		# Effects list and scrollbar
		#
		self << (@list = GuiList.new.set({:offset_x => -0.33, :offset_y => -0.07, :scale_x => 0.33, :scale_y => 0.865, :spacing_y => -0.8, :item_aspect_ratio => 4.0}))
		self << (@list_scrollbar = GuiScrollbar.new(@list).set({:offset_x => -0.154, :offset_y => -0.07, :scale_x => 0.025, :scale_y => 0.865}))
		@list.on_selection_change { on_list_selection_change }

		self << (@title = GuiLabel.new.set({:width => 30, :string => '', :offset_x => 0.19, :offset_y => 0.3, :scale_x => 0.58, :scale_y => 0.1}))
		self << (@description = GuiLabel.new.set({:width => 30, :string => '', :color => [1.0,1.0,1.0], :offset_x => 0.19, :offset_y => 0.2, :scale_x => 0.58, :scale_y => 0.06}))
		self << (@hint = GuiLabel.new.set({:width => 30, :string => '', :color => [0.7,0.7,0.7], :offset_x => 0.19, :offset_y => 0.1, :scale_x => 0.58, :scale_y => 0.06}))

		#
		# Close
		#
		self << (@close_button=GuiButton.new.set(:scale_x => 0.15, :scale_y => 0.07, :offset_x => 0.0, :offset_y => -0.5 + 0.035, :background_image => $engine.load_image('images/buttons/close.png')))
		@close_button.on_clicked { hide! }

		fill_from_category!
	end

	def clear_list!
		@list.clear!
		@title.set_string('')
		@description.set_string('')
		@hint.set_string('')
	end

	def fill_from_category!
		clear_list!

		find_valid_effect_classes.each { |object|
			next unless (@category.nil? || object.in_category?(@category))

			# wrap in a renderer
			renderer = GuiObjectRenderer.new(object)		# NOTE: we unwrap this in a few places

			# user selects an effect (class)
			renderer.on_clicked {
				if @selected_object == object
					add_object(@selected_object)
				else
					@list.set_selection(renderer)
				end
			}

			@list << renderer
		}
		@last_category = @category
	end

	def fill_from_search!
		clear_list!
		find_valid_effect_classes.select { |object| object.title.matches?(@search) }.each { |object|
			renderer = GuiObjectRenderer.new(object)		# NOTE: we unwrap this in a few places
			renderer.on_clicked {
				if @selected_object == object
					add_object(@selected_object)
				else
					@list.set_selection(renderer)
				end
			}
			@list << renderer
		}
		@list.set_selection(@list.first)
	end

	def on_list_selection_change
		return unless (selection = @list.selection.first)
		choose_object(selection.object)		# NOTE: undoing above wrapping
	end

	def choose_object(object)
		@selected_object = object
		create_for_object(object)
	end

	def create_for_object(object)
		@title.set_string(object.title)
		@description.set_string(object.description)
		@hint.set_string(object.hint)
	end

	# initiate callback
	def add_object(object)
		new_object = object.new
		new_object.after_load
		add_notify(new_object)
		end_search!		# ...
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
