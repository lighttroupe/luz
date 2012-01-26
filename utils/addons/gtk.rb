module Gtk
	def self.main_clear_queue
		while events_pending? do main_iteration_do(blocking = false) end
	end

	def self.non_expanding(widget)
		Gtk::HBox.new.add_tight(widget).add(Gtk::Label.new(''))
	end

	def self.hbox_for_widgets(widgets, spacing=3, border=1)
		hbox = Gtk::HBox.new(homogeneous = false, spacing).set_border_width(border)
		widgets.each { |w| hbox.add_tight(w) }
		return hbox
	end

	def self.vbox_for_widgets(widgets, spacing=6, border=1)
		vbox = Gtk::VBox.new(homogeneous = false, spacing).set_border_width(border)
		widgets.each { |w| vbox.add_tight(w) }
		return vbox
	end

	def self.idle_add_once
		idle_add { yield ; false } # false = don't call again
	end
end
