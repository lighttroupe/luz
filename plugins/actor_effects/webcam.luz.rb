# Copyright 2012 Ian McIntosh

$webcams ||= {}

class ActorEffectWebcam < ActorEffect
	title				"Webcam"
	description ""

	categories :color

	setting 'number', :integer, :range => 1..10, :summary => 'camera %'

	def after_load
		require 'video/video4linux2.rb'
		super
	end

	def render
		$webcams[number-1] ||= Video4Linux2::Camera.new("/dev/video#{number-1}", 1024, 768)
		$webcams[number-1].with_frame(offset=0) {
			yield
		}
	end
end
