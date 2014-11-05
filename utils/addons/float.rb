class Float
	def damper(target, damper)
		return target if ((self - target).abs < damper)
		self
	end

	def fuzzy?
		self >= 0.0 && self <= 1.0
	end

	def scale(low, high)
		#raise "scale called on float with bad value '#{self}'" unless self.fuzzy?
		low + self * (high - low)
	end

	def index_and_progress_to(high)
		return [high-1, 1.0] if self == 1.0

		(self * high).divmod(1.0)
	end

	def squared ; self * self	; end
	def cubed ; self * self * self ; end

	def square_root
		Math.sqrt(self)
	end

	def clamp(low, high)
		return low if self < low
		return high if self > high
		self
	end

	def clamp_fuzzy
		return 0.0 if self < 0.0
		return 1.0 if self > 1.0
		self
	end

	def time_format
		hours, remainder = self.divmod(3600.0)
		minutes, seconds = remainder.divmod(60.0)
		sprintf('%02d:%02d:%05.2f', hours, minutes, seconds)
	end

	def time_format_natural
		hours, remainder = self.divmod(3600.0)
		minutes, seconds = remainder.divmod(60.0)
		parts = []
		parts << hours.plural('hour', 'hours') if hours > 0
		parts << minutes.plural('minute', 'minutes') if minutes > 0
		parts << seconds.to_i.plural('second', 'seconds') if parts.empty? # Only show seconds if it's the only part
		parts.join(', ')
	end

	# TODO: consider moving this elsewhere as it uses $env
	def beats
		self * $env[:seconds_per_beat]
	end
	alias :beat :beats
end
