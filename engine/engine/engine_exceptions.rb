module EngineExceptions
	def user_object_try(obj)
		begin
			return yield if obj.usable?		# NOTE: doesn't yield for "crashed" UOs
		rescue Interrupt => e
			raise e
		rescue Exception => e
			obj.crashy = true
			obj.last_exception = e if $gui
			user_object_exception_notify(obj, e)
			user_object_changed_notify(obj)
		end
	end

	def safe
		begin
			yield
		rescue Interrupt => e
			raise e
		rescue Exception => e
			e.report
		end
	end
end
