module ChipmunkRenderHelpers
	def with_physical_body_position_and_rotation(drawable)
		# We needn't do this twice, as chipmunk has no 'child bodies'
		# This can get called recursively by massive groups' caching renderer
		return yield if $physical_body_positioned

		position = drawable.body.p
		with_translation(position.x, position.y) {
			with_roll_unsafe(-drawable.body.a / (2*Math::PI)) {
				$physical_body_positioned = true
				yield
				$physical_body_positioned = false
			}
		}
	end

	def render_physical_filled_rectangle(drawable)
		body = drawable.body
		position = body.p
		with_physical_body_position_and_rotation(drawable) {
			# == DISPLAY LIST ==
			drawable.display_list = GL.RenderCached(drawable.display_list) {
				with_color(drawable.level_object.options[:fill_color]) {
					with_translation(drawable.shape_offset.x, drawable.shape_offset.y) {
						with_scale(drawable.level_object.width, drawable.level_object.height) {
							with_optional_image(drawable.level_object.options) {
								unit_square_immediate
							}
						}
					}
				}
			}
			# == END DISPLAY LIST ==
		}
	end

	def render_physical_rectangle_render_actor(drawable)
		position = drawable.body.p
		with_physical_body_position_and_rotation(drawable) {
			with_translation(drawable.shape_offset.x, drawable.shape_offset.y) {
				with_scale(drawable.level_object.width, drawable.level_object.height) {
					with_env_for_actor(drawable) {
						drawable.render_actor.render!
					}
				}
			}
		}
	end

	def render_physical_rectangle_actor_effects(drawable)
		body = drawable.body
		position = body.p
		level_object = drawable.level_object
		options = level_object.options
		with_physical_body_position_and_rotation(drawable) {
			with_translation(drawable.shape_offset.x, drawable.shape_offset.y) {
				with_scale(level_object.width, level_object.height) {
					with_color(options[:fill_color]) {
						with_optional_image(options) {
							with_env_for_actor(drawable) {
								drawable.render_actor.render_recursive {
									unit_square
								}
							}
						}
					}
				}
			}
		}
	end

	#
	# Non-physical
	#
	def render_non_physical_rectangle_render_actor(drawable)
		level_object = drawable.level_object		# microcache
		with_translation(level_object.x, level_object.y) {
			with_roll_unsafe(drawable.angle) {
				with_scale_unsafe(level_object.width * drawable.scale_x, level_object.height * drawable.scale_y) {
					with_multiplied_alpha(level_object.options[:fill_color].alpha) {
						with_env_for_actor(drawable) {
							drawable.render_actor.render!
						}
					}
				}
			}
		}
	end

	def render_non_physical_rectangle_actor_effects(drawable)
		level_object = drawable.level_object
		with_translation(level_object.x, level_object.y, drawable.z) {
			with_roll(drawable.angle) {
				with_color(level_object.options[:fill_color]) {
					with_env_for_actor(drawable) {
						with_optional_image(level_object.options) {
							drawable.render_actor.render_recursive {
								with_scale_unsafe(level_object.width * drawable.scale_x, level_object.height * drawable.scale_y) {
									unit_square
								}
							}
						}
					}
				}
			}
		}
	end

	def render_static_rectangle(drawable)
		# == DISPLAY LIST ==
		drawable.display_list = GL.RenderCached(drawable.display_list) {			# TODO: drawable.z
			with_translation(drawable.level_object.x, drawable.level_object.y, drawable.z) {
				with_roll_unsafe(drawable.angle) {
					with_scale_unsafe(drawable.level_object.width * drawable.scale_x, drawable.level_object.height * drawable.scale_y) {
						with_color(drawable.level_object.options[:fill_color]) {
							with_optional_image(drawable.level_object.options) {
								unit_square_immediate
							}
						}
					}
				}
			}
		}
		# == END DISPLAY LIST ==
	end

	def render_static_rectangle_with_autoroll(drawable)
		# Map Feature: 'auto-roll' for rectangles/images
		with_translation(drawable.level_object.x, drawable.level_object.y, drawable.z) {
			with_roll_unsafe(drawable.angle + drawable.autoroll_angle) {		# <-- difference
				# == DISPLAY LIST ==
				drawable.display_list = GL.RenderCached(drawable.display_list) {
					with_scale(drawable.level_object.width * drawable.scale_x, drawable.level_object.height * drawable.scale_y) {
						with_color(drawable.level_object.options[:fill_color]) {
							with_optional_image(drawable.level_object.options) {
								unit_square_immediate
							}
						}
					}
				}
				# == END DISPLAY LIST ==
			}
		}
	end

	#
	# Polygons
	#
	def render_physical_polygon_with_render_actor(drawable)
		body = drawable.body
		with_offscreen_buffer { |buffer|
			# Capture image of render-actor to be used as texture for polygon
			buffer.using {
				drawable.render_actor.render!
			}
			buffer.with_image {
				with_physical_body_position_and_rotation(drawable) {
					# == DISPLAY LIST ==
					drawable.display_list = GL.RenderCached(drawable.display_list) {
						with_translation_unsafe(drawable.shape_offset.x, drawable.shape_offset.y, drawable.z) {
							with_texture_scale_and_translate(1.0 / drawable.level_object.width, 1.0 / drawable.level_object.height, drawable.level_object.width/2, drawable.level_object.height/2) { 
								render_filled_path(drawable.level_object.options[:shape_vertices], drawable.level_object.options)
							}
						}
					}
					# == END DISPLAY LIST ==
				}
			}
		}
	end

	def render_physical_polygon_with_actor_effects(drawable)
		body = drawable.body

		with_physical_body_position_and_rotation(drawable) {
			with_translation_unsafe(drawable.shape_offset.x, drawable.shape_offset.y, drawable.z) {
				with_color(drawable.level_object.options[:fill_color]) {
					with_env_for_actor(drawable) {
						drawable.render_actor.render_recursive {
							# == DISPLAY LIST ==
							drawable.display_list = GL.RenderCached(drawable.display_list) {
								render_filled_path(drawable.level_object.options[:shape_vertices], drawable.level_object.options)
							}
							# == END DISPLAY LIST ==
						}
					}
				}
			}
		}
	end

	def render_physical_polygon_filled(drawable)
		with_physical_body_position_and_rotation(drawable) {
			# == DISPLAY LIST ==
			drawable.display_list = GL.RenderCached(drawable.display_list) {
				with_translation(drawable.shape_offset.x, drawable.shape_offset.y, drawable.z) {
					with_color(drawable.level_object.options[:fill_color]) {
						with_optional_image(drawable.level_object.options) {
							render_filled_path(drawable.level_object.options[:shape_vertices], drawable.level_object.options)
						}
					}
				}
			}
			# == END DISPLAY LIST ==
		}
	end

	def render_static_polygon(drawable)
		# == DISPLAY LIST ==
		drawable.display_list = GL.RenderCached(drawable.display_list) {
			with_color(drawable.level_object.options[:fill_color]) {
				with_translation(0.0, 0.0, drawable.z) {
					with_optional_image(drawable.level_object.options) {
						render_filled_path(drawable.level_object.options[:shape_vertices], drawable.level_object.options)
					}
				}
			}
		}
		# == END DISPLAY LIST ==
	end

	def render_static_polygon_with_render_actor(drawable)
		with_offscreen_buffer { |buffer|
			# Capture image of render-actor to be used as texture for polygon
			buffer.using {
				drawable.render_actor.render!
			}
			buffer.with_image {
				# == DISPLAY LIST ==
				drawable.display_list = GL.RenderCached(drawable.display_list) {
					render_filled_path(drawable.level_object.options[:shape_vertices], drawable.level_object.options)
				}
				# == END DISPLAY LIST ==
			}
		}
	end

	def render_static_polygon_with_actor_effects(drawable)
		level_object = drawable.level_object
		with_color(level_object.options[:fill_color]) {
			with_translation(0.0, 0.0, as_float(level_object.options[:z])) {
				with_env_for_actor(drawable) {
					with_optional_image(level_object.options) {
						drawable.render_actor.render_recursive {
							# == DISPLAY LIST ==
							drawable.display_list = GL.RenderCached(drawable.display_list) {
								render_filled_path(level_object.options[:shape_vertices], level_object.options)
							}
							# == END DISPLAY LIST ==
						}
					}
				}
			}
		}
	end

	def render_spring(drawable)
		spring = drawable.constraint
		p1 = spring.body_a.p + spring.anchr1.rotate(CP::Vec2.for_angle(spring.body_a.a))
		p2 = spring.body_b.p + spring.anchr2.rotate(CP::Vec2.for_angle(spring.body_b.a))
		return if (p2-p1).lengthsq > 1		# don't draw insanely long lines

		with_color(drawable.level_object.options[:stroke_color]) {
			with_line_width(as_float(drawable.level_object.options[:stroke_width], 3.0)) {
				GL.Begin(GL::LINES)
					GL.Vertex(p1.x, p1.y)
					GL.Vertex(p2.x, p2.y)
				GL.End
			}
		}
	end
end
