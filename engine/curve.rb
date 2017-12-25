require 'parent_user_object'

class Curve < ParentUserObject
	title 'Curve'

	attr_reader :vector, :approximation

	def new_renderer
		GuiCurveRenderer.new(self)
	end

	def to_yaml_properties
		super + ['@vector', '@approximation']
	end

	def effects
		[]		# never has any
	end

	def after_load
		set_default_instance_variables(:title => 'New Curve', :vector => (0...9).to_a.collect {|x| x / 8.0 }, :approximation => [0.0, 1.0])
		super
	end

	def vector=(rhs)
		@vector, @last_x_unclamped = rhs, nil		# NOTE: Clears cached value
	end

	def approximation=(rhs)
		@approximation, @last_x_unclamped = rhs, nil		# NOTE: Clears cached value
	end

	def value(x_unclamped)
		return @last_value if x_unclamped == @last_x_unclamped		# Simple cache

		x = x_unclamped.clamp(0.0, 1.0)

		step_size = (1.0 / (@approximation.size - 1))

		ia = (x * (@approximation.size - 1)).floor.to_i
		ib = (ia + 1) % (@approximation.size)

		percent_between = (x - (ia * step_size)) / step_size

		@last_x_unclamped, @last_value = x_unclamped, percent_between.scale(@approximation[ia], @approximation[ib])
		@last_value
	end

	#
	# Helpers that describe the nature of the curve (used for coloring it and building lists of only eg. increasing/up curves)
	#
	def up?
		(@vector.first == 0.0) && (@vector.last == 1.0)
	end

	def down?
		(@vector.first == 1.0) && (@vector.last == 0.0)
	end

	def middle?
		(@vector.first == 0.5) && (@vector.last == 0.5)
	end

	def looping?
		@vector.first == @vector.last
	end

	def linear?
		up? && (@approximation.size == 2)
	end
end
