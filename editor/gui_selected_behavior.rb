module GuiSelectedBehavior
	def selected?
		@parent && @parent.respond_to?(:child_is_selected?) && @parent.child_is_selected?(self)
	end
end
