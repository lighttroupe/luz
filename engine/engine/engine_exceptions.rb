module EngineExceptions
	def user_object_try(obj)
		begin
			yield if obj.usable?		# NOTE: doesn't yield for "crashed" UOs
		rescue Interrupt => e
			raise e
		rescue Exception => e
			obj.crashy = true
			puts sprintf("#{'#'*80}\nOops! The plugin shown below has caused an error and has stopped functioning:\n\n%s\nObject:%s\n#{'#'*80}\n", e.report_format, obj.title)
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
