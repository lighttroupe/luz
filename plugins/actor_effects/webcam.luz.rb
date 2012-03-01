# Copyright 2012 Ian McIntosh

class ActorEffectWebcam < ActorEffect
	title				"Webcam"
	description ""

	def after_load
		require 'video/video4linux2.so'
		require 'video/video4linux2.rb'
		super
	end

	def render
		$webcam ||= Video4Linux2::Camera.new
		$webcam.with_frame(offset=0) {
			yield
		}
	end
end
