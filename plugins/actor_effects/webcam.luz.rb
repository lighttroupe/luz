# Copyright 2012 Ian McIntosh

class ActorEffectWebcam < ActorEffect
	title				"Webcam"
	description ""

	def after_load
		require 'video/video4linux2'
		super
	end

	def render
		$webcam ||= Video4Linux2::Camera.new
		@image ||= Image.new

		data = $webcam.data
		@image.from_rgb8(data, $webcam.width, $webcam.height)

		@image.using {
			yield
		}
	end
end
