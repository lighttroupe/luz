class VariableInputButtonManual < VariableInput
	title				"Button Manual"
	description "Send a constant activation level while button is pressed, 0% activation while button is not pressed."

	categories :button

	setting 'button', :button, :summary => true
	setting 'activation', :float, :range => 0.0..1.0, :default => 1.0..1.0

	def value
		if $engine.button_down?(button)
			activation
		else
			0.0
		end
	end
end
