# returns eg [1, 8, 7] or [1, 9, 1]
def ruby_version
	($ruby_version_split=RUBY_VERSION.split('.').map { |s| s.to_i })
end
