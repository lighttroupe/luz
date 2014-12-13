require 'user_object_setting'

class UserObjectSettingEvent < UserObjectSetting
	def to_yaml_properties
		super + ['@event']
	end

	attr_reader :event

	def now?
		@event ? (@event.do_value == true) : false
	end

	def on_this_frame?
		@event ? @event.on_this_frame? : false
	end

	def previous_frame?
		@event ? @event.previous_frame? : false
	end

	def count
		@event ? @event.count : 0
	end

	def summary
		summary_format(@event.title) if @event
	end
end
