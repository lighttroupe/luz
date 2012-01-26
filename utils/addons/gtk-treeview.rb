class Gtk::TreeView
	def initialize
		super
		signal_connect('key-press-event') { |obj, event|
			# Ctrl-Up and Ctrl-Down move selected rows
			if !model.sorted?
				if event.keyval == Gdk::Keyval::GDK_Up and event.state == Gdk::Window::ModifierType::CONTROL_MASK
					move_selected_up
					true # handled
				elsif event.keyval == Gdk::Keyval::GDK_Down and event.state == Gdk::Window::ModifierType::CONTROL_MASK
					move_selected_down
					true # handled
				end
			end
			false
		}

		# Basic drag-and-drop
		on_primary_mouse_button_down { |x, y|
			unless (selection.empty? or model.sorted?)
				@tree_view_rows_grabbed, @tree_view_grab_y = true, y
				Gtk.grab_add(self)
				window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::FLEUR))
			end
		}
		on_mouse_motion { |x, y|
			if @tree_view_rows_grabbed and !selection.empty?
				# drag distance (since click or last move)
				delta = (y - @tree_view_grab_y)

				if delta > 0
					# when dragging down, must drag below next cell's midway point
					cell_area = get_cell_area(selection.selected_iters.last.path, nil)
					if y > cell_area.y + cell_area.height + (cell_area.height / 2.0)
						# update grab point if we do move
						@tree_view_grab_y = y if move_selected_down
					end
				else
					cell_area = get_cell_area(selection.selected_iters.first.path, nil)
					if y < cell_area.y - (cell_area.height / 2.0)
						@tree_view_grab_y = y if move_selected_up
					end
				end
			end
		}
		on_primary_mouse_button_up {
			@tree_view_rows_grabbed = false
			Gtk.grab_remove(self)
			window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::ARROW))
		}
	end

	def cancel_row_grab
		@tree_view_rows_grabbed = false
	end

	def on_order_change(&proc)
		@on_order_change_proc = proc
	end

	def move_selected_up
		# if can't do 'prev!' then the first row is at the top, so we do nothing
		selection.selected_iters.each { |iter| path = iter.path ; return false unless path.prev! ; prev_iter = model.get_iter(path) ; move_before(iter, prev_iter) }
		@on_order_change_proc.call if @on_order_change_proc
		return true
	end

	def move_selected_down
		# if can't do 'next!' then the last row (processed first) is at the bottom, so we do nothing
		selection.selected_iters.reverse.each { |iter| next_iter = iter.dup ; return false unless next_iter.next! ; move_after(iter, next_iter) }
		@on_order_change_proc.call if @on_order_change_proc
		return true
	end

	def move_after(iter_to_move, after_iter)
		model.move_after(iter_to_move, after_iter)
	end

	def move_before(iter_to_move, before_iter)
		model.move_before(iter_to_move, before_iter)
	end

	# a source of segfaults in various ruby / gtk binding versions, deprecated for move_after/move_before
	#def swap_iters(iter_a, iter_b)
	#	model.swap(iter_a, iter_b)
	#end

	def clear
		model.clear
	end

	def on_selection_change
		selection.signal_connect('changed') { yield }
	end

	def each
		model.each { |model, path, iter| yield model, path, iter }
	end

	def each_iter
		model.each {|model, path, iter| yield iter }
	end

	def unselect_all
		selection.unselect_all
		self
	end

	def on_activated
		signal_connect('row-activated') { yield }
	end
end
