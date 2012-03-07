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
		attr_accessor :position, :place, :destination_place
		def initialize(x, y, place)
			@position = Vector3.new(x, y, 0.0)
			@place, @destination_place = place, nil
		end

		def tick(distance_per_frame)
			if @destination_place
				# Go!
				vector_to_destination = (@destination_place.position - position)
				distance_to_destination = vector_to_destination.length

				if distance_to_destination < distance_per_frame
					#puts "arrived!"
					position.set(@destination_place.position)
					@place, @destination_place = @destination_place, nil
				else
					# Move towards destination
					self.position += (vector_to_destination.normalize * distance_per_frame)
				end
			else
				@destination_place = place.neighbors.to_a.random
			end
		end
	end

	#
	# Game Network Graph
	#
	class Node
		attr_reader :position, :neighbors
		def initialize(x, y)
			@position = Vector3.new(x, y, 0.0)
			@neighbors = Set.new
		end

		def add_neighbor(node)
			@neighbors << node
		end

		def remove_neighbor(node)
			@neighbors.delete(node)
		end

		def clear_neighbors
			@neighbors.clear
		end
	end

	class Path
		attr_accessor :nodeA, :nodeB
		def initialize(nodeA, nodeB)
			@nodeA = nodeA
			@nodeB = nodeB

			@nodeA.add_neighbor(@nodeB)
			@nodeB.add_neighbor(@nodeA)
		end

		def center_point
			#[(@nodeA.position.x + @nodeB.position.x) / 2.0, (@nodeA.position.y + @nodeB.position.y) / 2.0]
			(@nodeA.position + @nodeB.position) / 2.0
		end

		def length
			@nodeA.position.distance_to(@nodeB.position)
		end

		def angle
			Math.atan2((@nodeB.position.x - @nodeA.position.x), (@nodeB.position.y - @nodeA.position.y)) / (Math::PI*2.0)
		end
	end

	class Portal < MapObject
	end

	class Base < MapObject
	end

	#
	# Point collection 
	#
	class Pellet < MapObject
	end

	#
	# Heroes, Enemies, Bases and Portals
	#
	class Hero < MapObject
#		def tick(distance_per_frame)
#			super(distance_per_frame)
#		end
	end

	class Enemy < MapObject
	end

	#
	# Map class
	#
	attr_accessor :nodes, :paths, :pellets, 
								:powerpellets, :floatingfruit, 
								:herobases, :enemybases, :portals, :heroes, :enemies

	def initialize
		@nodes, @paths, @pellets, @powerpellets, @floatingfruit,
		@herobases, @enemybases, @portals, @heroes, @enemies = [], [], [], [], [], [], [], [], [], []

		# game network layout (hard coded hack for testing currently)
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

		# pellets, power_pellets, floating fruit
		#@pellets << Pellet.new(-0.1, -0.1)
		#@powerpellets << Pellet.new(0.1, 0.1)
		#@floatingfruit << Pellet.new( -0.1, 0.1)

		# bases, portals
		@herobases << Base.new(@nodes.first.position.x, @nodes.first.position.y, @nodes.first)
		@enemybases << Base.new(@nodes.last.position.x, @nodes.last.position.y, @nodes.last)

		#@portals << Portal.new(0.0,0.0)
	end

	def spawn_hero
		base = @herobases.random
		@heroes << Hero.new(base.place.position.x, base.place.position.y, base.place) if base
	end

	def spawn_enemy
		base = @enemybases.random
		@enemies << Enemy.new(base.place.position.x, base.place.position.y, base.place) if base
	end
end

class DirectorEffectGamePacMap < DirectorEffect
	title	    'PacMap'
	description "The PacMap game in Luz"

	include Drawing

	setting 'node', :actor
	setting 'node_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'path', :actor
	setting 'path_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'hero', :actor
	setting 'hero_count', :integer, :range => 1..10, :default => 1..10
	setting 'hero_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'hero_speed', :float, :range => 0.0..1.0, :default => 0.01..1.0

	setting 'enemy', :actor
	setting 'enemy_count', :integer, :range => 1..10, :default => 1..10
	setting 'enemy_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'enemy_speed', :float, :range => 0.0..1.0, :default => 0.01..1.0

	setting 'pellet', :actor
	setting 'pellet_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

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

	#
	# after_load is called once at startup, and again after Ctrl-Shift-R reloads
	#
	def after_load
		@map = PacMap.new
		super
	end

	#
	# tick is called once per frame, before rendering
	#
	def tick
		# Spawn, if needed
		if $env[:frame_number] % 10 == 0		# a delay between spawns so they don't all pile up
			@map.spawn_hero if @map.heroes.size < hero_count
			@map.spawn_enemy if @map.enemies.size < enemy_count
		end

		# $env[:frame_time_delta]  see Engine#update_environment in engine/engine.rb for more data
		@map.heroes.each_with_index { |h, i|
			h.tick(hero_speed)
		}

		@map.enemies.each_with_index { |e, i|
			e.tick(enemy_speed)
		}
	end

	#
	# render is responsible for all drawing, and must yield to continue down the effects list
	#
	def render
		#
		# Paths
		#
		with_offscreen_buffer { |buffer|
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
		with_offscreen_buffer { |buffer|
			# Render to offscreen
			buffer.using {
				node.render!
			}
			# Render actor with image of rendered scene as default Image
			buffer.with_image {
				@map.nodes.each { |n|
					with_translation(n.position.x, n.position.y) {
						with_scale(node_size, node_size, node_size){
							unit_square
						}
					}
				}
			}
		}

		#
		# Hero Base
		#
		with_offscreen_buffer { |buffer|
			# Render to offscreen
			buffer.using {
				herobase.render!
			}
			# Render actor with image of rendered scene as default Image
			buffer.with_image {
				@map.herobases.each { |n|
					with_translation(n.position.x, n.position.y) {
						with_scale(herobase_size, herobase_size, herobase_size){
							unit_square
						}
					}
				}
			}
		}

		#
		# Enemy Base
		#
		with_offscreen_buffer { |buffer|
			# Render to offscreen
			buffer.using {
				enemybase.render!
			}
			# Render actor with image of rendered scene as default Image
			buffer.with_image {
				@map.enemybases.each { |n|
					with_translation(n.position.x, n.position.y) {
						with_scale(enemybase_size, enemybase_size, enemybase_size){
							unit_square
						}
					}
				}
			}
		}

=begin
		#
		# Portals
		#
		with_offscreen_buffer { |buffer|
			# Render to offscreen
			buffer.using {
				portal.render!
			}
			# Render actor with image of rendered scene as default Image
			buffer.with_image {
				@map.portals.each { |n|
					with_translation(n.position.x, n.position.y) {
						with_scale(portal_size, portal_size, portal_size){
							unit_square
						}
					}
				}
			}
		}

		#
		# Pellets
		#
		with_offscreen_buffer { |buffer|
			# Render to offscreen
			buffer.using {
				pellet.render!
			}
			# Render actor with image of rendered scene as default Image
			buffer.with_image {
				@map.pellets.each { |n|
					with_translation(n.position.x, n.position.y) {
						with_scale(pellet_size, pellet_size, pellet_size){
							unit_square
						}
					}
				}
			}
		}

		#
		# Power Pellets
		#
		with_offscreen_buffer { |buffer|
			# Render to offscreen
			buffer.using {
				powerpellet.render!
			}
			# Render actor with image of rendered scene as default Image
			buffer.with_image {
				@map.powerpellets.each { |n|
					with_translation(n.position.x, n.position.y) {
						with_scale(powerpellet_size, powerpellet_size, powerpellet_size){
							unit_square
						}
					}
				}
			}
		}

		#
		# Floating Fruit
		#
		with_offscreen_buffer { |buffer|
			# Render to offscreen
			buffer.using {
				floatingfruit.render!
			}
			# Render actor with image of rendered scene as default Image
			buffer.with_image {
				@map.floatingfruit.each { |n|
					with_translation(n.position.x, n.position.y) {
						with_scale(floatingfruit_size, floatingfruit_size, floatingfruit_size){
							unit_square
						}
					}
				}
			}
		}
=end

		#
		# Heros
		#
		@map.heroes.each_with_index { |h, i|
			with_env(:child_index, i) {
				with_translation(h.position.x, h.position.y) {
					with_scale(hero_size, hero_size, hero_size){
						with_roll(0.25) {
							hero.render!
						}
					}
				}
			}
		}

		#
		# Enemies
		#
		@map.enemies.each_with_index { |e, i|
			with_env(:child_index, i) {
				with_translation(e.position.x, e.position.y) {
					with_scale(enemy_size, enemy_size, enemy_size){
						with_roll(0.25) {
							enemy.render!
						}
					}
				}
			}
		}

		yield
	end
end
