 ###############################################################################
 #  Copyright 2008 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

class EasyDialog
	def initialize(parent, options)
		@parent, @options = parent, options
		create
	end

	def show
		# doesn't seem to work: @dialog.set_default_response(@options[:default].to_i) if @options[:default]
		@dialog.signal_connect('response') { @dialog.destroy }		# Ensure it's destroyed when user responds
		@dialog.show_all
	end

	def show_modal
		# doesn't seem to work: @dialog.set_default_response(@options[:default].to_i) if @options[:default]
		@dialog.run { |response| @dialog.destroy ; return response.to_sym }
	end

private

	def create
		@dialog = Gtk::Dialog.new(@options[:title] || '').set_has_separator(false) #, @parent)
		@dialog.vbox.set_spacing(12)

		content_hbox = Gtk::HBox.new.set_spacing(12).set_border_width(12)

		# Add dialog icon
		if @options[:icon]
			icon = Gtk::Image.new(Gtk::Stock.const_get('DIALOG_' + @options[:icon].to_s.upcase), Gtk::IconSize::DIALOG)
			content_hbox.pack_start(icon, false)
		end

		text_vbox = Gtk::VBox.new.set_spacing(6)

		# Add header text (optional)
		if @options[:header]
			text_vbox.add(Gtk::Label.new.set_markup("<big><b>#{@options[:header]}</b></big>").set_alignment(0.0, 0.0))
		end
		# Add body text (optional)
		if @options[:body]
			text_vbox.add(Gtk::Label.new.set_markup(@options[:body]).set_alignment(0.0, 0.0))
		end
		content_hbox.add(text_vbox)

		@dialog.vbox.add(content_hbox.show_all)

		#button_hbox = Gtk::HBox.new.set_spacing(6)
		@options[:buttons].each { |settings|
			# settings is [:unique_token, 'Label', :stock_id_in_symbol_form]
			button = Gtk::Button.new(settings[1])

			# Set image (optional)
			button.set_image(Gtk::Image.new(Gtk::Stock.const_get(settings[2].to_s.upcase), Gtk::IconSize::BUTTON)) if settings[2]

			@dialog.add_action_widget(button.show, settings[0].to_i)
		}
	end
end
