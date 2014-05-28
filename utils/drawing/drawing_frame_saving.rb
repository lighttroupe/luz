module DrawingFrameSaving
	def frame_saving_requested?
		($max_previous_frame_requested || 0) > 0
	end

	def with_frame_saving
		#
		throw "with_frame_saving must not be called unless frame_saving_requested? returns true" unless frame_saving_requested?

		$max_previous_frame_requested ||= 0

		#puts "$previous_frames is not big enough" if $previous_frames.size < ($max_previous_frame_requested + 1)
		$previous_frames << get_offscreen_buffer while $previous_frames.size < ($max_previous_frame_requested + 1)
		#puts "now it has #{$previous_frames.size} frames"

		$previous_frames_current_frame_index = ($previous_frames_current_frame_index + 1) % $previous_frames.size
		#puts "saving to #{$previous_frames_current_frame_index}"

		target_buffer = $previous_frames[$previous_frames_current_frame_index]
		yield target_buffer
	end
	#conditional :with_frame_saving

	def with_texture_of_previous_frame(number_back)
		if $previous_frames and $previous_frames.size >= number_back
			index = $previous_frames_current_frame_index - number_back
			index += $previous_frames.size if index < 0
			#puts "chosen index=#{index} which has fbo_id=#{$previous_frames[index]}"

			$previous_frames[index].with_image {
				yield
			}
		else
			$previous_frames ||= []
			$previous_frames_current_frame_index ||= 0
			$max_previous_frame_requested ||= 0

			# we DON'T YIELD which will of course end rendering for this object-- until the frame can be generated
			$max_previous_frame_requested = number_back if number_back > $max_previous_frame_requested
			#puts "(with_texture_of_previous_frame is not yielding $max_previous_frame_requested=#{$max_previous_frame_requested})"
			# TODO: limit this number
		end
	end
end
