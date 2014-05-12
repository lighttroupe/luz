class NilClass		# generally helpful for eg. nil instance variables thought to be holding images
	def using
		yield
	end

	def blank?
		true
	end
end
