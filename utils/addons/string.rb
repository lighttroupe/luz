class String
	def matches?(search_string)
		search_words = search_string.downcase.split(' ')
		return false if search_words.empty?

		self_downcased = self.downcase
		search_words.all? { |word| self_downcased.include? word }
	end

	# Adds spaces between capitalized words and converts underscores to spaces
	def humanize
		gsub(/([A-Z]+)([A-Z][a-z])/, '\1 \2').
		gsub(/([a-z\d])([A-Z])/, '\1 \2').
		gsub(/_/, ' ').
		split(' ').collect { |w| w.capitalize }.join(' ')
	end

	def has_prefix?(prefix)
		self[0, prefix.length] == prefix		# TODO: faster way to implement this?
	end

	def without_prefix(prefix)
		return self[prefix.length, self.length - prefix.length] if has_prefix?(prefix)
		self
	end

	def has_suffix?(suffix)
		self[-suffix.length, suffix.length] == suffix		# TODO: faster way to implement this?
	end

	def without_suffix(suffix)
		return self[0, self.length - suffix.length] if has_suffix?(suffix)
		self
	end

	def blank?
		strip.length == 0
	end
end
