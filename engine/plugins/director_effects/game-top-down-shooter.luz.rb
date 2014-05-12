	 ###############################################################################
 #  Copyright 2011 Ian McIntosh <ian@openanswers.org>
 #
 #  This program is free software; you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation; either version 2 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU Library General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program; if not, write to the Free Software
 #  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 ###############################################################################

include Drawing

class DirectorEffectGameTopDownShooter < DirectorEffect
	title				'Top Down Shooter'
	description ''

	setting 'ship', :actor
	setting 'ship_size', :float, :range => 0.001..1.0, :default => 0.1..1.0
	setting 'ship_x', :float, :range => 0.0..1.0, :default => 0.5..1.0
	setting 'ship_y', :float, :range => 0.0..1.0
	setting 'ship_launch_time', :timespan, :allow_instant => false
	setting 'ship_death_time', :timespan, :allow_instant => false
	setting 'ship_weapon_change', :event

	setting 'shoot', :event
	setting 'shoot_period', :timespan

	setting 'bullet', :actor
	setting 'bullet_size', :float, :range => 0.001..1.0, :default => 0.1..1.0
	setting 'bullet_speed', :float, :range => 0.001..4.0, :default => 0.1..1.0

	setting 'laser', :actor
	setting 'laser_width', :float, :range => 0.001..1.0, :default => 0.05..1.0
	setting 'laser_damage_per_second', :float, :range => 0.001..100.0, :default => 0.5..1.0
	setting 'laser_activation_time', :timespan

	setting 'laser_hit', :actor
	setting 'laser_hit_size', :float, :range => 0.001..1.0, :default => 0.05..1.0

	#
	# explosion when an enemy is destroyed
	#
	setting 'explosion', :actor
	setting 'explosion_size', :float, :range => 0.001..1.0, :default => 0.1..1.0
	setting 'explosion_time', :timespan

	#
	#
	#
	setting 'enemies', :actors
	setting 'enemy_size', :float, :range => 0.001..1.0, :default => 0.1..1.0
	setting 'enemy_speed', :float, :range => 0.001..100.0, :default => 0.1..1.0
	setting 'enemy_death_time', :timespan
	setting 'enemy_damage_variable', :variable

	#
	# Scor
	#
	setting 'score_per_enemy_killed', :float, :range => -1.0..1.0, :default => 0.01..1.0
	setting 'score_per_enemy_passed', :float, :range => -1.0..1.0, :default => -0.1..1.0

	ENEMY_STARTING_HEALTH = 1.0

	patterns_light = [
								[[-1,0], [0,0], [1,0], [-1,1], [0,1], [1,1], [-1,2], [0,2], [1,2], [-1,3], [0,3], [1,3]],		# 9s
								[[0,0], [-1,0], [-1,1], [-1,2], [0,2], [1,2], [1,1], [1,0]],	# O shape
								[[0,0], [-1,1], [0,2], [1,1]],																# diamond shape
								[[0,0], [-1,1], [-2,2], [1,1], [2,2]],												# Flying V
								[[0,0], [-2,2], [2,2]],
								[[0,0], [-1,1], [1,1]],																				# Mini V
							]

	patterns_heavy = [
								[[1,0], [0,0], [-1,0], [-2,0]],																# horizontal line
								[[0,0], [0,1], [0,2], [0,3]],																	# vertical line
							]

	patterns_bombs = [
								[[0,0]],																											# solo
							]

	EnemyType = Struct.new(:damage_modifier, :movement_proc, :patterns)
	ENEMY_TYPES = [
									# Enemy 1 - Light
									EnemyType.new(1.0, Proc.new { |enemy| [0.0, -0.2] }, patterns_light),
									# Enemy 2 - Heavy
									EnemyType.new(0.15, Proc.new { |enemy| [(fuzzy_cosine($env[:beat]) - 0.5) * 0.5, (((enemy.state == :alive) ? (fuzzy_sine($env[:beat]) - 0.5) : 0.0) - 0.1) * 0.5] }, patterns_heavy ),
									# Enemy 3 - SuperLight
									EnemyType.new(2.0, Proc.new { |enemy| [$env[:beat_number].is_odd? ? -0.1 : 0.1, -0.3] }, patterns_light ),
									# Enemy 4 - Bomb
									EnemyType.new(0.25, Proc.new { |enemy| [0.0, fuzzy_cosine($env[:time]) - 0.5 - 0.1] }, patterns_bombs )
								]

	def birth
		puts 'birth'
	end

	#
	# after_load is called once when object is first created, and also after an engine reload
	# it must call 'super' for the object to be properly instantiated
	#
	Bullet = Struct.new(:x, :y, :velocity_x, :velocity_y, :actor)
	Enemy = Struct.new(:x, :y, :health, :damage_modifier, :actor, :state, :child_index, :state_start_time, :movement_proc)
	Explosion = Struct.new(:x, :y, :start_time, :life_time, :actor)

	require 'struct-stack'
	def after_load
		@bullets, @bullet_stack = [], StructStack.new(Bullet)
		@enemies, @enemy_stack = [], StructStack.new(Enemy)
		@explosions, @explosion_stack = [], StructStack.new(Explosion)

		@last_shoot_time = 0.0
		@ship_state = :alive
		@ship_state_start_time = 0.0
		@score = 0.0
		@ship_weapon = :bullets

		super
	end

	#
	# tick is called once per frame, before rendering
	#
	def tick
		frame_time_delta = $env[:frame_time_delta]

		if ship_weapon_change.now?
			# HACK
			@ship_weapon = (@ship_weapon == :bullets ? :laser : :bullets)
		end

		#
		# Shoot!
		#
		if @ship_state == :alive and shoot.now?

			# laser
#			if @last_shoot_time < $env[:time]

			# bullets

			if (@ship_weapon == :bullets) && (@last_shoot_time < ($env[:time] - shoot_period.to_seconds))
				bullet.one { |b|
					# spread
					@bullets << @bullet_stack.pop(ship_x - (ship_size / 2.0), ship_y, -bullet_speed / 10.0, bullet_speed, b)
					@bullets << @bullet_stack.pop(ship_x, ship_y, 0.0, bullet_speed, b)
					@bullets << @bullet_stack.pop(ship_x + (ship_size / 2.0), ship_y, bullet_speed / 10.0, bullet_speed, b)

					# double
					#@bullets << @bullet_stack.pop(ship_x - ship_size / 2.0, ship_y, 0.0, bullet_speed, b)
					#@bullets << @bullet_stack.pop(ship_x + ship_size / 2.0, ship_y, 0.0, bullet_speed, b)
				}
				@last_shoot_time = $env[:time]
			end
		end

		#
		# Spawn new enemies
		#
		if @enemies.count < 5 or $env[:frame_number] % 40 == 0
			@enemy_choice ||= 0
			@enemy_choice += 1
			@enemy_choice %= enemies.count if enemies.count > 0

			spawn_enemy_group
		end

		#
		# Bullet vs Enemy collisions
		#
		bullet_enemy_collision_distance_squared = (bullet_size/2.0 + enemy_size/2.0)**2
		@bullets.delete_if { |b|
			# offscreen?
			if b.y > 1.0
				# recycle
				@bullet_stack.push(b)
				true
			else
				# update
				b.x += b.velocity_x * frame_time_delta
				b.y += b.velocity_y * frame_time_delta

				hit = false

				# Check for collisions
				@enemies.each { |e|
					if e.state == :alive and ((e.x - b.x)**2 + (e.y - b.y)**2 < bullet_enemy_collision_distance_squared)
						e.health -= (1.0 * e.damage_modifier)

						if e.health <= 0.0
							#
							# Enemy destruction
							#
							explosion.one { |explosion|
								@explosions << @explosion_stack.pop(e.x, e.y, $env[:time], explosion_time.to_seconds, explosion)
							}
							e.state = :dying
							e.state_start_time = $env[:time]
							$engine.on_button_press('Game 01 / Enemy / Destroyed', 1)
							@score += score_per_enemy_killed
						end
						hit = true
						break
					end
				}
				hit
			end
		}

		if @ship_weapon == :laser
			@laser_activation ||= 0.0
			@laser_hit_x = nil
			@laser_hit_y = nil
			if @ship_state == :alive and shoot.now? and true # laser
				@laser_activation = (@laser_activation + (laser_activation_time.instant? ? 1.0 : ($env[:frame_time_delta] / laser_activation_time.to_seconds))).clamp(0.0, 1.0)

				e = @enemies.select { |e| e.state == :alive and (e.y > ship_y) and (e.x - ship_x).abs < (laser_width/2.0 + enemy_size/2.0 ) }.sort { |a,b| a.y <=> b.y }.first
				if e
					@laser_hit_x = ship_x - 0.5
					@laser_hit_y = (e.y - enemy_size/2.0) - 0.5

					e.health -= (@laser_activation * laser_damage_per_second * $env[:frame_time_delta] * e.damage_modifier)

					if e.health <= 0.0
						e.state = :dying
						e.state_start_time = $env[:time]
						$engine.on_button_press('Game 01 / Enemy / Destroyed', 1)
						@score += score_per_enemy_killed
					end
				else
				end
			else
				@laser_activation = (@laser_activation - (laser_activation_time.instant? ? 1.0 : ($env[:frame_time_delta] / laser_activation_time.to_seconds))).clamp(0.0, 1.0)
			end
		end

		#
		# Update ship
		#
		case @ship_state
		when :alive
			player_enemy_collision_distance_squared = (ship_size/2.0 + enemy_size/2.0)**2
			@enemies.each { |e|
				if e.state == :alive and ((e.x - ship_x)**2 + (e.y - ship_y)**2 < player_enemy_collision_distance_squared)
					# player dies
					@ship_state = :dying
					@ship_state_start_time = $env[:time]
					$engine.on_button_press('Game 01 / Player 01 / Destroyed', 1)

					# ship dies too
					e.state = :dying
					e.state_start_time = $env[:time]
					$engine.on_button_press('Game 01 / Enemy / Destroyed', 1)
					hit = true
					break
				end
			}
		when :dying
			if ($env[:time] - @ship_state_start_time) > ship_launch_time.to_seconds
				@ship_state = :starting
				@ship_state_start_time = $env[:time]
			end

		when :starting
			if ($env[:time] - @ship_state_start_time) > ship_launch_time.to_seconds
				@ship_state = :alive
				@ship_state_start_time = $env[:time]
			end
		end

		#
		# Update enemies
		#
		@enemies.delete_if { |e|
			# offscreen?
			if e.y < 0.0
				# recycle
				@enemy_stack.push(e)
				@score += score_per_enemy_passed
				true
			elsif e.state == :dying and ($env[:time] - e.state_start_time) > enemy_death_time.to_seconds
				# recycle
				@enemy_stack.push(e)
				true
			else
				# update
				#e.y -= (e.speed * $env[:frame_time_delta])
				delta_x, delta_y = e.movement_proc.call(e)
#puts "x:#{delta_x}, y:#{delta_y}"

				e.x += (delta_x * $env[:frame_time_delta] * enemy_speed)
				e.y += (delta_y * $env[:frame_time_delta] * enemy_speed)
				false
			end
		}

		$engine.on_slider_change('Game 01 / Progress', @score.clamp(0.0, 1.0))
	end

	#
	# render is responsible for all drawing, and must yield to continue down the effects list
	#
	def render
		enemy_death_time_in_seconds = enemy_death_time.to_seconds

		@bullets.each { |b|
			with_translation(b.x - 0.5, b.y - 0.5) {
				with_scale(bullet_size) {
					b.actor.render!
				}
			}
		}

		@enemies.each { |e|
			with_translation(e.x - 0.5, e.y - 0.5) {
				with_scale(enemy_size) {
					with_enter_and_exit(1.0, (e.state == :dying) ? (($env[:time] - e.state_start_time) / enemy_death_time_in_seconds) : 0.0) {
						with_env(:child_index, e.child_index) {
							# Set variables
							enemy_damage_variable_setting.with_value(1.0 - (e.health / ENEMY_STARTING_HEALTH)) {
								e.actor.render!
							}
						}
					}
				}
			}
		}

		if (@ship_weapon == :laser and @laser_hit_x)
			with_translation(@laser_hit_x, @laser_hit_y) {
				with_scale(laser_hit_size) {
					laser_hit.render!
				}
			}
		end

		with_translation(ship_x - 0.5, ship_y - 0.5) {
			# laser shooting?
			if @ship_weapon == :laser and @ship_state == :alive and (shoot.now? or @laser_activation > 0.0)
				with_enter_and_exit(@laser_activation, 0.0) {
					with_scale(laser_width, 1.0) {
						if @laser_hit_y
							with_horizontal_clip_plane_above(@laser_hit_y - ship_y + 0.5) {
								laser.render!
							}
						else
							laser.render!
						end
					}
				}
			end

			with_scale(ship_size) {
				with_enter_and_exit((@ship_state == :starting) ? (($env[:time] - @ship_state_start_time) / ship_launch_time.to_seconds).clamp(0.0, 1.0) : 1.0, (@ship_state == :dying) ? (($env[:time] - @ship_state_start_time) / ship_death_time.to_seconds).clamp(0.0, 1.0) : 0.0) {
					ship.render!
				}
			}
		}

		@explosions.delete_if { |explosion|
			with_translation(explosion.x - 0.5, explosion.y - 0.5) {
				with_scale(explosion_size) {
					with_enter_exit_progress(($env[:time] - explosion.start_time) / explosion.life_time) {
						explosion.actor.render!
					}
				}
			}
			(($env[:time] - explosion.start_time) >= explosion.life_time)
		}
		yield
	end

	def spawn_enemy_group
		enemies.one(@enemy_choice) { |e|
			x = rand * 0.6 + 0.2
			enemy_type = ENEMY_TYPES[@enemy_choice] #.random
			pattern = enemy_type.patterns.random_element

			pattern.each_with_index { |x_y, index|
				@enemies << @enemy_stack.pop(x + (enemy_size * x_y[0]), 1.0 + (enemy_size/2.0) + (enemy_size * x_y[1]), ENEMY_STARTING_HEALTH, enemy_type.damage_modifier, e, :alive, index, $env[:time], enemy_type.movement_proc)
			}
		}
	end
end
