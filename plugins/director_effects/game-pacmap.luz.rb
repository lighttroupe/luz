 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
 #  Copyright 2012 Scott Lee Davis <skawtus@gmail.com>
 ###############################################################################

include Drawing

class Map
	attr_accessor :nodes, :paths
	
	class Node
		attr_reader :x, :y, :neighbors
		
		def initialize(x, y)
			@x = x
			@y = y
			@neighbors = []
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
		end
	end
	
	def initialize
		@nodes = []
		@paths = []
		
		# Add some test data
		@nodes << (a=Node.new(-0.25, 0.0))
		@nodes << (b=Node.new(0.25, 0.0))
		a.add_neighbor(b)
		b.add_neighbor(a)
		p = Path.new(a, b)
		@paths << p	
	end
end

class DirectorEffectGamePacMap < DirectorEffect
	title	    'PacMap'
	description "The PacMap game in Luz"

	setting 'hero', :actor
	setting 'enemy', :actor
	setting 'node', :actor
	setting 'node_size', :float

	#
	# after_load is called once at startup, and again after Ctrl-Shift-R reloads
	#
	def after_load
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
		# TODO: draw map and creatures
		@map ||= Map.new

		@map.nodes.each { |n|
			with_translation( n.x, n.y ){
				with_scale(node_size,node_size){
				node.render!
				}
			}
		}

		yield
	end
end
