require 'conditions'

=begin
	Child Index:
		( ) Every Nth [2 ⟠] Starting at [0 ⟠]
		[ ] Invert

	Event:
		( ) When [event ⟠] () is on () is off

	Context:
		( ) Always
		( ) Studio
		( ) Performance
=end

class ChildConditions < Conditions
	attr_accessor :event, :child_index_min, :child_index_max
	boolean_accessor :enable_child_index, :enable_event, :event_invert

	def to_yaml_properties
		['@enable_child_index', '@child_index_min', '@child_index_max', '@enable_event', '@event', '@event_invert'] + super
	end

	def initialize
		@enable_child_index = false
		@child_index_min = 0
		@child_index_max = 0

		@enable_event = false
		@event = nil
		@event_invert = false
	end

	#
	# When conditions are satisfied, object can be used normally.
	#
	def satisfied?
		event_satisfied? && child_index_satisfied?
	end

	def child_index_satisfied?
		@enable_child_index == false || ($env[:child_index] >= @child_index_min && $env[:child_index] <= @child_index_max)
	end

	def event_satisfied?
		@enable_event == false || @event.nil? || (@event.now? == (@event_invert ? false : true))		# to deal with possible nil (no after_creation method for non userobjects :/)
	end

	def child_number_min
		@child_index_min + 1
	end
	def child_number_min=(num)
		@child_index_min = num - 1
		@child_index_max = @child_index_min if @child_index_min > @child_index_max
	end

	def child_number_max
		@child_index_max + 1
	end
	def child_number_max=(num)
		@child_index_max = num - 1
		@child_index_min = @child_index_max if @child_index_min > @child_index_max
	end

	def summary_in_pango_markup(highlight_tag = 'u')
		lines = []
		if @enable_event and @event
			lines << ("only while #{@event.title.with_pango_tag(highlight_tag)}" + (@event_invert ? " is off" : " is on"))
		end

		if @enable_child_index
			if @child_index_min == @child_index_max
				lines << ("only child #{@child_index_min + 1}")
			else
				lines << ("only children #{@child_index_min + 1} to #{@child_index_max + 1}")
			end
		end

		if lines.empty?
			''
		else
			'  ' + lines.join("\n  ")
		end
	end
end
