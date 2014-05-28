class ActorEffectImageSeriesProgress < ActorEffect
	title				"Image Series Progress"
	description "Apply one of a series of images to actor, selected by percentage."

	categories :color

	hint "Supports animated GIFs, and will some day also support video files."

	setting 'image', :image, :summary => true
	setting 'progress', :float, :default => 0.0..1.0

	def render
		image_setting.using_progress(progress) {
			yield
		}
	end
end
