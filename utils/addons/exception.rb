class Exception
	def report_format(during_operation = nil)
		str = ''
		str += "Exception caught while #{during_operation}:\n" if during_operation
		str += "#{self.class}: #{self.message}" + self.backtrace.map { |line| "\n\tfrom #{line}" }.join + "\n"
		str
	end

	def report(during_operation = nil)
		puts report_format(during_operation)
	end
end
