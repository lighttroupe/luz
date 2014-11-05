module GL
	def self.SaveMatrix
		begin
			self.PushMatrix
			yield
		ensure
			self.PopMatrix
		end
	end

	def self.PushAll
		begin
			GL.PushAttrib(GL::ALL_ATTRIB_BITS)
			GL.PushMatrix
			yield
		ensure
			GL.PopMatrix
			GL.PopAttrib
		end
	end

	# Generates display list (using yield block)
	# call like   display_list = GL.RenderCached(display_list) { GL.calls... }
	def self.RenderCached(list)
		list ||= RenderToList { yield }		# Generate, if necessary
		return nil unless list						# For nested calls to RenderToList
		GL.CallList(list)
		return list
	end

	def self.RenderToList
		if $rendering_to_list
			# OpenGL can't define lists recursively, so instead we include the
			# contents of the inner list in the outer one
			yield
			return nil
		else
			list = GL.GenLists(1)
			GL.NewList(list, GL::COMPILE)
				$rendering_to_list = true
				yield
				$rendering_to_list = false
			GL.EndList
			return list
		end
	end

	def self.DestroyList(list)
		GL.DeleteLists(list, 1)
	end

	def self.GetColorArray
		GL.GetDoublev(GL::CURRENT_COLOR)
	end

	def self.GenTexture
		GenTextures(1).first
	end
end
