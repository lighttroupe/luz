#
# GuiObjectRenderer renders an object (usually a UserObject) without reparenting it
#
class GuiObjectRenderer < GuiObject
	callback :clicked
	callback :double_clicked

	attr_reader :object

	def initialize(object)
		@object = object
	end

	def ==(object)		# useful for being found in lists, etc.
		super || (@object == object)
	end

	pipe :gui_tick, :object

	#
	# rendering
	#
	def gui_render
		return if hidden?
		gui_render_background
		@object.gui_render		# TODO: send a symbol for customizable render method (ie simple curves)
	end

	#
	# pointer
	#
	def click(pointer)
		clicked_notify(pointer)
	end

	def double_click(pointer)
		double_clicked_notify(pointer)
	end
end
