$webcams ||= {}

class ActorEffectWebcam < ActorEffect
	title				"Webcam"
	description ""

	categories :color

	setting 'number', :integer, :range => 1..10, :summary => 'camera %'

	def render
		require 'webcam/video4linux2.rb' and @loaded = true unless @loaded

		$webcams[number-1] ||= Video4Linux2::Camera.new("/dev/video#{number-1}", 1024, 768)
		$webcams[number-1].with_frame(offset=0) {
			yield
		}
	end
end
