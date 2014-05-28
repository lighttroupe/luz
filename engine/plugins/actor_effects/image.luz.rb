class ActorEffectImage < ActorEffect
	title				"Image"
	description "Apply an image to actor."

	category :color

	setting 'image', :image, :summary => true

	def render
		image_setting.using {
			yield
		}
	end
end
