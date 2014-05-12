class Class
	def inherited_from?(klass)
		self.ancestors.include?(klass) and self != klass		# NOTE: ancestors[] includes the class itself
	end
end
