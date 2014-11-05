module EngineExceptions
	def user_object_try(obj)
		begin
			yield if obj.usable?		# NOTE: doesn't yield for "crashed" UOs
		rescue Interrupt => e
			raise e
		rescue Exception => e
			obj.crashy = true
			obj.last_exception = e
			user_object_exception_notify(obj, e)
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
