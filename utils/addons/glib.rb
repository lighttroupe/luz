# Overwrite the method at /usr/lib/ruby/1.8/glib2.rb:37 (on Ubuntu Feisty), which
# has broken our ability to receive exceptions in our own code, and instead hands
# us a SystemExit exception (from the call to exit() on line 45) every time.
module GLib
	def exit_application(status, other)
		puts "(ignoring call to GLib::exit_application(#{status}), see #{__FILE__}:#{__LINE__} for details)"
		raise		# re-raise to be caught by our main loop exception handling below
	end
	module_function :exit_application
end
