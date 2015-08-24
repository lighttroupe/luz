class UserObjectSettingColor
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label

		row = GuiHBox.new.set(:scale_y => 0.5, :offset_y => 0.15)
			row << GuiFloat.new(self, :red, 0.0, 1.0, 2).set(:text_align => :center, :scale_x => 0.15, :float => :left)
			row << GuiFloat.new(self, :green, 0.0, 1.0, 2).set(:text_align => :center, :scale_x => 0.15, :float => :left)
			row << GuiFloat.new(self, :blue, 0.0, 1.0, 2).set(:text_align => :center, :scale_x => 0.15, :float => :left)

			#row << (@animation_max_widget=GuiFloat.new(self, :animation_max, @min, @max, digits).set(:text_align => :center, :scale_x => 0.15, :float => :left, :opacity => 0.0, :hidden => true))
			#row << (@animation_every_text=GuiLabel.new.set(:width => 4, :text_align => :fill, :string => 'every', :offset_x => 0.014, :scale_x => 0.08, :float => :left, :opacity => 0.0, :hidden => true))

		box << row

		box
	end

	pipe [:red], :color
	pipe [:blue], :color
	pipe [:green], :color

	def red=(r)
		@color.red = r
		clear_cache!
	end

	def green=(g)
		@color.green = g
		clear_cache!
	end

	def blue=(b)
		@color.blue = b
		clear_cache!
	end

	def clear_cache!
		$gui.user_object.clear_render_styles_cache! if $gui.user_object && $gui.user_object.respond_to?(:clear_render_styles_cache!)		# hack to update theme icon
	end
end
