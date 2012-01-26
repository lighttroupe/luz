class Gtk::Viewport
	def draggable!
		on_primary_mouse_button_down { |x, y| @grabbed, @grab_x, @grab_y = true, x, y ; window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::FLEUR))  }
		on_mouse_motion { |x, y|
			if @grabbed
				delta = (x - @grab_x)
				max_scroll = hadjustment.upper - allocation.width		# total size - viewport size
				hadjustment.value = (hadjustment.value - delta).clamp(0, max_scroll + 2)

				delta = (y - @grab_y)
				max_scroll = vadjustment.upper - allocation.height		# total size - viewport size
				vadjustment.value = (vadjustment.value - delta).clamp(0, max_scroll + 2)
			end
		}
		on_primary_mouse_button_up { @grabbed = false ; window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::ARROW)) }
	end
end
