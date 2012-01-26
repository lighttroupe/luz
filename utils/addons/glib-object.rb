class GLib::Object
	alias :old_signal_connect :signal_connect

	def signal_connect(signal_name, &proc)
		s = old_signal_connect(signal_name) { |*args|
			begin
				proc.call(*args)
			rescue Exception => e
				e.report("in signal handler ('#{signal_name}')")
			end
		}
	end
end
