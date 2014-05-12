class String
	def limit(max_length, indicator='...')
		return self[0, max_length] + indicator if length > max_length
		return self
	end

	def shift(n)
		text = self[0, n]
		self[0, n] = ''		# shift string left, removing word
		return text
	end

	def next_word
		strip!		# TODO: strip is wrong: it removes whitespace from both ends of the string
		space_index = index(' ')
		return self if space_index.nil?
		return shift(space_index)
	end

	def begins_with?(string)
		self.index(string) == 0
	end

	def matches?(search_string)
		search_words = search_string.downcase.split(' ')
		return false if search_words.empty?

		search_words.all? { |word| self.include? word }

		# Each search word must match consecutive self.words eg. "music visuals".match?("m vis") == true
		#string_words = self.split(' ')
		#return false if search_words.size > string_words.size
#
		#search_words.each_with_index { |search_word, index|
			#return false unless string_words[index].begins_with? search_word
		#}
		#return true
	end

	# Adds spaces between capitalized words and converts underscores to spaces
	def humanize
		return self.
			gsub(/([A-Z]+)([A-Z][a-z])/, '\1 \2').
			gsub(/([a-z\d])([A-Z])/, '\1 \2').
			gsub(/_/, ' ').
			split(' ').collect { |w| w.capitalize }.join(' ')
	end

	def to_lowercase_underscored
		return self.
			gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
			gsub(/([a-z\d])([A-Z])/, '\1_\2').
			gsub(/ /, '_').downcase
	end

	def has_prefix?(prefix)
		self[0, prefix.length] == prefix		# TODO: faster way to implement this?
	end

	def without_prefix(prefix)
		return self[prefix.length, self.length - prefix.length] if has_prefix?(prefix)
		return self
	end

	def has_suffix?(suffix)
		self[-suffix.length, suffix.length] == suffix		# TODO: faster way to implement this?
	end

	def without_suffix(suffix)
		return self[0, self.length - suffix.length] if has_suffix?(suffix)
		return self
	end

	def blank?
		strip.length == 0
	end
end
