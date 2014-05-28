class ActorEffectImageSpriteProgress < ActorEffect
	title				"Image Sprite Progress"
	description "Apply one frame of animation from a 'sprite', selected by percentage."

	categories :color

	hint "Supports images containing multiple frames, spaced equally, either horizontally or vertically."

	setting 'image', :image, :summary => true
	setting 'number', :integer, :range => 1..256, :default => 1..2
	setting 'progress', :float, :range => 0.0..1.0, :default => 0.0..1.0
	setting 'direction', :select, :options => [[:auto, 'Auto'],[:horizontal, 'Horizontal'],[:vertical, 'Vertical']], :default => :auto

	def render
		image.using {
			# wide images are animated horizontally, tall ones vertically
			if (direction == :horizontal) or ((direction == :auto) and (image.width > image.height))
				with_texture_scale_and_translate(1.0 / number, 1, number.choose_index_by_fuzzy(progress), 0) {
					yield
				}
			else
				with_texture_scale_and_translate(1, 1.0 / number, 0, number.choose_index_by_fuzzy(progress)) {
					yield
				}
			end
		}
	end
end
