module SafeEval
	def safe_eval(code)
		code.split("\n").each { |line|
			if line =~ /send_slider\('(.*)'\, (\d\.\d)\)/
				$engine.on_slider_change($1, $2.to_f)
			elsif line =~ /send_button_press\('(.*)'\)/
				$engine.on_button_press($1, 1)
			elsif line =~ /send_button_up\('(.*)'\)/
				$engine.on_button_up($1)
			else
				puts "unhandled safe_eval line: #{line}"
			end
		}
	end
end
