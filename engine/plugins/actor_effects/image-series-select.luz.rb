class ActorEffectImageSeriesSelect < ActorEffect
	title				"Image Series Select"
	description "Apply one of a series of images to actor, selected by forwards and backwards events."

	categories :color

	hint "Supports animated GIFs, and will some day also support video files."

	setting 'image', :image, :summary => true

	setting 'forwards', :event
	setting 'backwards', :event

	def render
		image_setting.using_index(forwards.count - backwards.count) {
			yield
		}
	end
end
