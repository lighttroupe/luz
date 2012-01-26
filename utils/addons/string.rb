class String
	def with_pango_tag(tag)
		return "<#{tag}>#{self}</#{tag}>"
	end

	def with_optional_pango_tag(bool, tag)
		return self.with_pango_tag(tag) if bool
		return self
	end

	def pango_escaped
		self.gsub('&', '&amp;')
	end

	def pango_unescaped
		self.gsub('&amp;', '&')
	end
end
