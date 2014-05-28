class ActorImage < Actor
	virtual		# deprecated for 1.0

	title				"Image"
	description "A basic rectangle with an image."

	setting 'image', :image

	def render
		image_setting.using {
			unit_square
		}
	end
end
