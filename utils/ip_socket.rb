class IPSocket
	def set_reuse_address_flag
		setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
		self
	end
end
