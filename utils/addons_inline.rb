#require 'inline'
#class Object
#	include Inline
#	def self.easy_inline(str)
#		inline do |builder|
#			builder.c str
#		end
#	end
#end

section('Inlining common methods') {

class Object
	include Inline
end

class Float
	inline do |builder|
		builder.c "
			double scale(double low, double high) {
				return (low + (RFLOAT(self)->value * (high - low)));
			}"

		builder.c "
			double clamp(double low, double high) {
				double v = RFLOAT(self)->value;

				if(v < low)
					return low;

				if(v > high)
					return high;

				return v;
			}"
	end
end

class UserObjectSettingFloat
=begin
	def immediate_value
		# NOTE: Don't do any value caching here, as we need to resolve in various contexts in a single frame
		@last_value = @current_value

		# Get value of animation (any float value)
		if @enable_animation
			result = @animation_curve.value(animation_progress($env[:birth_time], $env[:birth_beat])).scale(@animation_min, @animation_max)
		else
			result = @animation_min		# Use 'animation_min' as constant value (see the GUI)
		end

		if @enable_activation and @activation_variable
			variable_value = $engine.variable_value(@activation_variable.title)
			# TODO: special case 0.0 or 1.0?
			if @activation_direction == :from
				result = @activation_curve.value(variable_value).scale(@activation_value, result)
			else # :to
				result = @activation_curve.value(variable_value).scale(result, @activation_value)
			end
		end
		# Enter Animation (scales from enter_value to animation_value on the enter_curve)
		if @enable_enter_animation
			result = @enter_curve.value($env[:enter]).scale(@enter_value, result)
		end
		# Exit Animation (scales from exit_value to animation_value on the exit_curve)
		if @enable_exit_animation
			result = @exit_curve.value($env[:exit]).scale(result, @exit_value)
		end
		return (@current_value = result.clamp(@min, @max))	# Never return anything outside (@min to @max)
	end

	inline do |builder|
		builder.c "
			double immediate_value() {
				VALUE env = rb_gv_get(\"$env\");

				VALUE animation_curve = rb_iv_get(self, \"@animation_curve\");
				VALUE animation_min = rb_iv_get(self, \"@animation_min\");
				VALUE animation_max = rb_iv_get(self, \"@animation_max\");

				// Save this
				VALUE current_value = rb_iv_get(self, \"@current_value\");
				rb_iv_set(self, \"@last_value\", current_value);

				// Get value of animation (any float value)
				if(rb_iv_get(self, \"@enable_animation\") == Qtrue) {
					// Some values from $env
					VALUE env_birth_time = rb_funcall(env, rb_intern(\"fetch\"), 1, ID2SYM(rb_intern(\"birth_time\")));
					VALUE env_birth_beat = rb_funcall(env, rb_intern(\"fetch\"), 1, ID2SYM(rb_intern(\"birth_beat\")));

					// THE RUBY: result = @animation_curve.value(animation_progress($env[:birth_time], $env[:birth_beat])).scale(@animation_min, @animation_max)

//printf(\"birth=%f,%f\\n\", RFLOAT(env_birth_time), RFLOAT(env_birth_beat));

					VALUE animation_progress = rb_funcall(self, rb_intern(\"animation_progress\"), 2, env_birth_time, env_birth_beat);

printf(\"progress=%f\\n\", RFLOAT(animation_progress));

					// Scale it: low + self * (high - low)
					VALUE result = animation_min + ((animation_progress) * (animation_max - animation_min));

					VALUE max = rb_iv_get(self, \"@max\");
					VALUE min = rb_iv_get(self, \"@min\");
					result = (RFLOAT(result) < RFLOAT(min)) ? min : ((RFLOAT(result) > RFLOAT(max)) ? max : result);
					rb_iv_set(self, \"@current_value\", result);
					return result;
				}

				return 0.5;
			}"
	end
=end
end

class Curve
	inline do |builder|
		builder.c "
			double value(double x_unclamped) {
				double x = ((x_unclamped > 1.0) ? 1.0 : x_unclamped);
				x = ((x < 0.0) ? 0.0 : x);

				VALUE approximation = rb_iv_get(self, \"@approximation\");
				int approximation_len = RARRAY(approximation)->len;

				double step_size = (1.0 / (double)(approximation_len - 1));

				int ia = (int)(x * (double)(approximation_len - 1));
				int ib = (ia + 1) % (approximation_len);

				double percent_between = (x - ((double)ia * step_size)) / step_size;

				double low = RFLOAT(rb_ary_entry(approximation, ia))->value;
				double high = RFLOAT(rb_ary_entry(approximation, ib))->value;

				return (low + (percent_between * (high - low)));
			}"
	end
end

}
