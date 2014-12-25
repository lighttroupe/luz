class GuiConfirmationDialog < GuiWindow
	callback :yes
	callback :no

	def initialize(title, description, yes_text, no_text)
		super()
		@title, @description, @yes_text, @no_text = title, description, yes_text, no_text
		create!
	end

	def create!
		self << (@background = GuiObject.new.set(:background_image => $engine.load_image('images/file-dialog-background.png')))
		self << (@title_label = GuiLabel.new.set({:width => 20, :text_align => :center, :color => [0.6,0.6,1.0], :string => @title, :offset_x => 0.0, :offset_y => 0.47, :scale_x => 0.30, :scale_y => 0.05}))
		self << (@description_label = GuiLabel.new.set({:width => 15, :text_align => :center, :color => [0.9,0.6,0.6], :string => @description, :offset_x => 0.0, :offset_y => 0.4, :scale_x => 0.25, :scale_y => 0.05}))

		self << (@yes_button = GuiLabel.new.set({:width => 15, :text_align => :center, :color => [0.5,1.0,0.5], :string => @yes_text, :offset_x => 0.2, :offset_y => 0.0, :scale_x => 0.25, :scale_y => 0.05}))
		@yes_button.on_clicked { |pointer| yes_notify(pointer) }
		self << (@no_button = GuiLabel.new.set({:width => 15, :text_align => :center, :color => [0.5,1.0,0.5], :string => @no_text, :offset_x => -0.2, :offset_y => 0.0, :scale_x => 0.25, :scale_y => 0.05}))
		@no_button.on_clicked { |pointer| no_notify(pointer) }
	end
end