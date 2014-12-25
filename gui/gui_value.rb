# base class for all Gui objects that show/edit a single instance variable on an object
class GuiValue < GuiObject
	def initialize(object, method)
		super()
		@object, @method_get, @method_set = object, method, (method.to_s+'=').to_sym
	end

	def get_value
		@object.send(@method_get)
	end

	def set_value(value)
		@object.send(@method_set, value)
		$engine.project_changed!		# heads up!  this project needs saving now
	end
end
