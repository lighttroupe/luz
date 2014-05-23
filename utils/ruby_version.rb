# returns eg [1, 8, 7] or [1, 9, 1]
def ruby_version
	RUBY_VERSION.split('.').map(&:to_i)
end
