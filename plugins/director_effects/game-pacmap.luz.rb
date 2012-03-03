 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
 #  Copyright 2012 Scott Lee Davis <skawtus@gmail.com>
 ###############################################################################

include Drawing

require 'set'

class PacMap
	class Node
		attr_reader :x, :y, :neighbors

		def initialize(x, y)
			@x = x
			@y = y
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
			[(@nodeA.x + @nodeB.x) / 2.0, (@nodeA.y + @nodeB.y) / 2.0]
		end

		def length
			Math.sqrt((@nodeA.x - @nodeB.x)**2 + (@nodeA.y - @nodeB.y)**2)
		end

		def angle
			Math.atan2((@nodeB.x - @nodeA.x), (@nodeB.y - @nodeA.y)) / (Math::PI*2.0)
		end
	end

	class Character
		attr_accessor :x, :y
		def initialize(x, y)
			@x, @y = x, y
		end
	end

	#
	# Map class
	#
	attr_accessor :nodes, :paths, :heroes, :enemies

	def initialize
		@nodes, @paths, @heroes, @enemies = [], [], [], []

		# Add some test data
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

		@heroes << Character.new(@nodes.first.x, @nodes.first.y)
		@enemies << Character.new(@nodes.last.x, @nodes.last.y)
	end
end

class DirectorEffectGamePacMap < DirectorEffect
	title	    'PacMap'
	description "The PacMap game in Luz"

	setting 'hero', :actor
	setting 'hero_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'enemy', :actor
	setting 'enemy_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'node', :actor
	setting 'node_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'path', :actor

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
		# $env[:frame_time_delta]  see Engine#update_environment in engine/engine.rb for more data
	end

	#
	# render is responsible for all drawing, and must yield to continue down the effects list
	#
	def render
		@map.paths.each { |p|
			center = p.center_point
			with_translation(center.first, center.last) {
				with_roll(p.angle) {
					with_scale(node_size, p.length) {
						path.render!
					}
				}
			}
		}

		@map.nodes.each { |n|
			with_translation(n.x, n.y) {
				with_scale(node_size,node_size){
					node.render!
				}
			}
		}

		# Heros
		@map.heroes.each { |h|
			with_translation(h.x, h.y) {
				with_scale(hero_size, hero_size){
					with_roll(0.25) {
						hero.render!
					}
				}
			}
		}

		# Enemies
		@map.enemies.each { |e|
			with_translation(e.x, e.y) {
				with_scale(enemy_size, enemy_size){
					with_roll(0.25) {
						enemy.render!
					}
				}
			}
		}

		yield
	end
end
