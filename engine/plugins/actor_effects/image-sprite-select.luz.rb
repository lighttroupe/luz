class ActorEffectImageSpriteSelect < ActorEffect
	title				"Image Sprite Select"
	description "Apply one frame of animation from a 'sprite', selected by forwards and backwards events."

	categories :color

	hint "Supports images containing multiple frames, spaced equally, either horizontally or vertically."

	setting 'image', :image, :summary => true
	setting 'number', :integer, :range => 1..256, :default => 1..2

	setting 'forwards', :event
	setting 'backwards', :event

	def render
		image.using {
			# wide images are animated horizontally, tall ones vertically
			if image.width > image.height
				with_texture_scale_and_translate(1.0 / number, 1, (forwards.count - backwards.count) % number, 0) {
					yield
				}
			else
				with_texture_scale_and_translate(1, 1.0 / number, 0, (forwards.count - backwards.count) % number) {
					yield
				}
			end
		}
	end
end
