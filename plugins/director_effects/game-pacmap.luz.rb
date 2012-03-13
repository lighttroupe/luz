 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
 #  Copyright 2012 Scott Lee Davis <skawtus@gmail.com>
 ###############################################################################

require 'set'
require 'vector3'

class PacMap

	#
	# Base class for all movable objects
	#
	class MapObject
		attr_accessor :position, :place, :destination_place, :angle

		include Engine::MethodsForUserObject

		def initialize(x, y, place)
			@position = Vector3.new(x, y, 0.0)
			@place, @destination_place = place, nil
			@entered_at, @enter_time = $env[:frame_time], 0.2		# TODO: configurable?
			@exited_at, @exit_time = nil, 0.5		# TODO: configurable?
			@angle = 0.0
		end

		def tick(distance_per_frame)
			if @exited_at
				# nothing
			elsif @destination_place
				vector_to_destination = (@destination_place.position - position)
				distance_to_destination = vector_to_destination.length

				@angle = vector_to_destination.fuzzy_angle % 1.0		# maintain in 0.0..1.0 range for use in Variable

				# Arrived?
				if distance_to_destination < distance_per_frame
					position.set(@destination_place.position)
					@place, @destination_place = @destination_place, nil
				else
					# Move towards destination
					self.position += (vector_to_destination.normalize * distance_per_frame)
				end
			else
				@destination_place = place.random_neighbor
			end
		end

		def with_env_for_actor
			enter = (@entered_at) ? (($env[:frame_time] - @entered_at) / @enter_time) : 1.0
			exit = (@exited_at) ? (($env[:frame_time] - @exited_at) / @exit_time) : 0.0
			with_enter_and_exit(enter, exit) {
				yield
			}
		end

		def exit!
			@exited_at ||= $env[:frame_time]
		end

		def exiting?
			!@exited_at.nil?
		end
	end

	#
	# Game Network Graph
	#
	class Node
		attr_reader :position

		def initialize(x, y)
			@position = Vector3.new(x, y, 0.0)
			@neighbors = Set.new
		end

		def add_neighbor(node)
			@neighbors << node
		end

		def random_neighbor
			@neighbors.to_a.random
		end
	end

	class Path
		attr_accessor :node_a, :node_b, :vector, :length, :angle, :center_point

		def initialize(node_a, node_b)
			@node_a, @node_b = node_a, node_b

			@node_a.add_neighbor(@node_b)
			@node_b.add_neighbor(@node_a)
			calculate!
		end

		def calculate!
			@vector = (@node_b.position - @node_a.position)
			@length = @vector.length
			@angle = @vector.fuzzy_angle
			@center_point = (@node_a.position + @node_b.position) / 2.0
		end
	end

	class Portal < MapObject
	end

	class Base < MapObject
	end

	#
	# Characters
	#
	class Hero < MapObject
	end

	class Enemy < MapObject
	end

	class Pellet < MapObject
	end

	#
	# Map class
	#
	attr_accessor :nodes, :paths, :portals, :herobases, :enemybases,
								:heroes, :enemies, :pellets, :powerpellets, :floatingfruit

	def initialize
		@nodes, @paths, @portals, @herobases, @enemybases = [], [], [], [], []
		@pellets, @powerpellets, @heroes, @enemies, @floatingfruit = [], [], [], [], []

		#
		# game network layout (hard coded hack for testing currently)
		#
		@nodes << (a=Node.new(0.2, 0.0))
		@nodes << (b=Node.new(-0.2, 0.0))
		@paths << Path.new(a, b)

		@nodes << (c=Node.new(0.0, 0.3))
		@paths << Path.new(a, c)
		@paths << Path.new(c, b)

		@nodes << (d=Node.new(0.2, -0.3))
		@paths << Path.new(a, d)

		@nodes << (e=Node.new(-0.2, -0.3))
		@paths << Path.new(b, e)

		# bases, portals
		@herobases << Base.new(@nodes.first.position.x, @nodes.first.position.y, @nodes.first)
		@enemybases << Base.new(@nodes.last.position.x, @nodes.last.position.y, @nodes.last)
	end

	#
	# Spawning
	#
	def spawn_hero
		base = @herobases.random
		@heroes << Hero.new(base.place.position.x, base.place.position.y, base.place) if base
	end

	def spawn_enemy
		base = @enemybases.random
		@enemies << Enemy.new(base.place.position.x, base.place.position.y, base.place) if base
	end

	def spawn_pellets!(pellet_spacing, node_size)
		@paths.each { |path|
			usable_length = (path.length - node_size)		# avoid placing pellets over nodes (node_size/2 on each end)
			pellet_count = (usable_length / pellet_spacing).floor
			padding = (usable_length - ((pellet_count - 1) * pellet_spacing))		# -1 because pellet spacing is between nodes ie 3 (*--*--*) has pellet_spacing*2
			start_position = (path.node_a.position + (path.vector.normalize * ((node_size / 2.0) + (padding / 2.0))))		# half spacing on each side
			step = (path.vector.normalize * pellet_spacing)

			# Layout pellets
			pellet_count.times { |i|
				position = start_position + (step * i)
				@pellets << Pellet.new(position.x, position.y, path)
			}
		}
	end

	def exit_characters!
		@heroes.each { |hero| hero.exit! }
		@enemies.each { |hero| hero.exit! }
	end

	def remove_characters!
		@heroes.clear
		@enemies.clear
	end
end

class DirectorEffectGamePacMap < DirectorEffect
	title				'PacMap'
	description 'PacMan, Luz-style.'

	include Drawing

	setting 'node', :actor
	setting 'node_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'path', :actor
	setting 'path_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'hero', :actor
	setting 'hero_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'hero_speed', :float, :range => 0.0..1.0, :default => 0.01..1.0
	setting 'hero_count', :integer, :range => 1..10, :default => 1..10

	setting 'enemy', :actor
	setting 'enemy_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'enemy_speed', :float, :range => 0.0..1.0, :default => 0.01..1.0
	setting 'enemy_count', :integer, :range => 1..10, :default => 1..10

	setting 'pellet', :actor
	setting 'pellet_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'pellet_spacing', :float, :range => 0.0..1.0, :default => 0.03..1.0, :simple => true

	setting 'powerpellet', :actor
	setting 'powerpellet_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'floatingfruit', :actor
	setting 'floatingfruit_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'herobase', :actor
	setting 'herobase_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'enemybase', :actor
	setting 'enemybase_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'portal', :actor
	setting 'portal_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'character_angle_variable', :variable

	#
	# after_load is called once at startup, and again after Ctrl-Shift-R reloads
	#
	def after_load
		@map = PacMap.new
		start_pregame!
		super
	end

	#
	# tick is called once per frame, before rendering
	#
	def tick
		case @state
		when :pregame
			start_game! if players_ready?

		when :game
			game_tick

		when :postgame
			@countdown -= 1
			start_pregame! if @countdown == 0

		else
			raise "unhandled game state #{@state}"
		end
	end

	def start_pregame!
		@state = :pregame
		@map.remove_characters!
	end

	def players_ready?
		true
	end

	def start_game!
		@map.spawn_pellets!(pellet_spacing, node_size)
		@state = :game
	end

	def game_tick
		# Spawn if needed
		if $env[:frame_number] % 10 == 0		# a delay between spawns so they don't all pile up
			@map.spawn_hero if @map.heroes.size < hero_count
			@map.spawn_enemy if @map.enemies.size < enemy_count
		end

		#
		# Tick characters
		#
		hit_distance = (hero_size / 2)

		# do long distances in multiple steps to avoid jumping over things in one big update
		steps = (hero_speed / pellet_spacing).floor + 1		# TODO: tweak this formula

		@map.heroes.each { |hero|
			steps.times {
				hero.tick(hero_speed / steps)

				# Heroes vs Pellets
				@map.pellets.delete_if { |pellet|
					hero.position.distance_to(pellet.position) < hit_distance
				} unless hero.exiting?
			}
		}
		@map.enemies.each { |enemy|
			enemy.tick(enemy_speed)
		}

		# Heroes win?
		end_game! if @map.pellets.empty?
	end

	def end_game!
		@map.exit_characters!
		@state = :postgame
		@countdown = 30		# TODO: time based?
	end

	#
	# render is responsible for all drawing, and must yield to continue down the effects list
	#
	def render
		#
		# Paths
		#
		with_offscreen_buffer(:medium) { |buffer|
			# Render to offscreen
			buffer.using {
				path.render!
			}

			# Render actor with image of rendered scene as default Image
			buffer.with_image {
				@map.paths.each { |p|
					center = p.center_point
					with_translation(center.x, center.y) {
						with_roll(p.angle) {
							with_scale(path_size, p.length, path_size) {
								unit_square
							}
						}
					}
				}
			}
		}

		#
		# Nodes
		#
		render_list_via_offscreen_buffer(@map.nodes, node_size, :medium) {
			node.render!
		}

		#
		# Hero Base
		#
		render_list_via_offscreen_buffer(@map.herobases, herobase_size, :medium) {
			herobase.render!
		}

		#
		# Enemy Base
		#
		render_list_via_offscreen_buffer(@map.enemybases, enemybase_size, :medium) {
			enemybase.render!
		}

=begin
		#
		# Portals
		#
		@map.portals.each_with_index { |p, i|
			with_character_setup(p, portal_size, i) {
				portal.render!
			}
		}
=end

		#
		# Pellets
		#
		render_list_via_offscreen_buffer(@map.pellets, pellet_size, :small) {
			pellet.render!
		}

=begin
		#
		# Power Pellets
		#
		render_list_via_offscreen_buffer(@map.powerpellets, powerpellet_size, :small) {
			powerpellet.render!
		}

		#
		# Floating Fruit
		#
		render_list_via_offscreen_buffer(@map.floatingfruits, floatingfruit_size, :small) {
			floatingfruit.render!
		}
=end

		#
		# Heros
		#
		@map.heroes.each_with_index { |h, i|
			with_character_setup(h, hero_size, i) {
				hero.render!
			}
		}

		#
		# Enemies
		#
		@map.enemies.each_with_index { |e, i|
			with_character_setup(e, enemy_size, i) {
				enemy.render!
			}
		}

		yield
	end

	#
	# render helpers
	#
	def render_list_via_offscreen_buffer(characters, size, buffer_size)
		with_offscreen_buffer(buffer_size) { |buffer|
			# Render to offscreen
			buffer.using {
				yield
			}
			# Render actor with image of rendered scene as default Image
			buffer.with_image {
				characters.each { |character|
					with_translation(character.position.x, character.position.y) {
						with_scale(size, size, size){
							unit_square
						}
					}
				}
			}
		}
	end

	def with_character_setup(character, size, index)
		character.with_env_for_actor {
			with_env(:child_index, index) {
				character_angle_variable_setting.with_value(character.angle) {
					with_translation(character.position.x, character.position.y) {
						with_scale(size, size, size){
							yield
						}
					}
				}
			}
		}
	end
end
