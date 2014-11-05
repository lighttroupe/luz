# A setting (color, length) for UserObjects (Actors, Effects)
require 'drawing'

class UserObjectSetting
	include Drawing

	TAB_LABEL_MARKUP = '<small><small>%s</small></small>'
	TAB_LABEL_HIGHLIGHT_MARKUP = '<small><small><span color="white"><u>%s</u></span></small></small>'

	TIME_UNIT_OPTIONS = [[:seconds, 'Seconds'], [:minutes, 'Minutes'], [:hours, 'Hours'], [:beats, 'Beats']]
	REPEAT_NUMBER_RANGE = 0.1..999

	TIME_UNIT_SHORT = {:seconds => 'sec', :minutes => 'mins', :hours => 'hrs', :beats => 'beats'}

	# Called by widget code when something changes.
	callback :change

	attr_accessor :parent
	attr_reader :name, :last_value
	attr_writer :options

	def initialize(parent, name, options={})
		@parent, @name, @options = parent, name, options
		after_load
	end

	empty_method :after_load, :value			# NOTE: default value returns nil

	def merge_options(options)
		@options.merge!(options)
	end

	def to_yaml_properties
		['@name', '@options', '@breaks_cache']
	end

	def files_used
		[]
	end

	def shader?
		@options[:shader] == true
	end

	def get(method)
		instance_variable_get("@#{method}")
	end

	def set(method, value)
		instance_variable_set("@#{method}", value)
		handle_on_change_option
		change_notify
	end

	def handle_on_change_option
		return unless parent
		case @options[:on_change]
		when Symbol
			parent.send @options[:on_change]
		when Proc
			@options[:on_change].call(parent)
		end
	end

	def unit_and_number_to_time(unit, number)
		case unit
		when :seconds then return number.to_f
		when :minutes then return number.to_f * 60.0
		when :hours then return number.to_f * 3600.0
		when :beats then return number.to_f / $env[:bps]
		else raise "unhandled time unit '#{unit}'"
		end
	end

	def unit_and_number_to_beats(unit, number)
		case unit
		when :seconds then return $env[:bps]
		when :minutes then return $env[:bps] * 60.0
		when :hours then return $env[:bps] * 3600.0
		when :beats then return number
		else raise "unhandled time unit '#{unit}'"
		end
	end

	def breaks_cache?
		@options[:breaks_cache] || false
	end

	# What a plugin gets when it uses the name of the setting (as it were a local variable, while in fact it is a method)
	def immediate_value
		self
	end

	def uses_enter?
		false
	end

	def uses_exit?
		false
	end

	#
	# Summary
	#
	empty_method :summary

	def summary_format(text)
		return nil unless text

		case @options[:summary]
		when String
			@options[:summary].sub('%', text)
		when TrueClass
			text
		when FalseClass, NilClass
			nil
		else
			puts "user-object-setting warning: unhandled option (:summary) in summary_format: #{@options[:summary]}"
		end
	end
end
