 ###############################################################################
 #  Copyright 2012 Ian McIntosh <ian@openanswers.org>
 #  Copyright 2012 Scott Lee Davis <skawtus@gmail.com>
 ###############################################################################

require 'set'
require 'vector3'
require 'fileutils'

# 
# PacMap: base game login class, handles character, network layout, game logic, hit testing and character input
#
class PacMap

	#
	# MapObject: base class for all movable objects (e.g. objects that live on Nodes and Paths)
	#
	class MapObject
		attr_accessor :position, :node, :destination_node, :path, :angle

		include Engine::MethodsForUserObject

		def initialize(x, y, node)
			@position = Vector3.new(x, y, 0.0)
			@node, @destination_node = node, nil
			move_to_node!
			reset_enter_exit!
			@angle = 0.0
		end

		def warp_to(node)
			@node, @destination_node = node, nil
			move_to_node!
		end

		def reset_enter_exit!
			@entered_at, @enter_time = $env[:frame_time], 0.2		# TODO: configurable?
			@exited_at, @exit_time = nil, 0.5		# TODO: configurable?
		end

		#
		# tick: per timestep iteration of game logic
		#
		def tick(distance_per_frame)
			if exiting?
				# nothing
			else
				choose_destination!

				if @destination_node
					vector_to_destination = (@destination_node.position - position)
					distance_to_destination = vector_to_destination.length

					@angle = vector_to_destination.fuzzy_angle if distance_to_destination > 0.0		# maintain in 0.0..1.0 range for use in Variable

					# Arrived?
					if distance_to_destination < distance_per_frame
						position.set(@destination_node.position)
						@node, @destination_node = @destination_node, nil
					else
						# Move towards destination
						self.position += (vector_to_destination.normalize * distance_per_frame)
					end
				end
			end
		end

		def choose_destination!
			choose_random_destination!
		end

		def choose_random_destination!
			@destination_node ||= node.random_neighbor
		end

		def path_find(from_node, to_node)
			#closed = Set.new							# set of nodes already evaluated
			#open = Set.new([from_node])		# set of tentative nodes to be evaluated
		end

		def with_enter_and_exit_for_actor
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

		def exited?
			(@exited_at) ? (($env[:frame_time] - @exited_at) > @exit_time) : false
		end

		def move_to_node!
			@position = @node.position.dup if @node.respond_to? :position
		end
	end

	#
	# Graph Network Node
	#
	class Node
		attr_reader :position
		attr_accessor :special

		def initialize(x, y)
			@position = Vector3.new(x, y, 0.0)
			@neighbors = Set.new
		end

		def add_neighbor(node)
			@neighbors << node unless (node == self)
		end

		def remove_neighbor(node)
			@neighbors.delete(node)
		end

		def random_neighbor
			@neighbors.to_a.random
		end

		def each_neighbor
			@neighbors.each { |n| yield n }
		end

		def each_neighbor_with_fuzzy_angle
			@neighbors.delete(self)		# HACK to remove bad data from some saved maps
			@neighbors.each { |node|
				angle = position.vector_to(node.position).fuzzy_angle
				yield node, angle
			}
		end
	end

	#
	# Graph Network Path
	#
	class Path
		attr_accessor :node_a, :node_b, :vector, :length, :angle, :center_point
		attr_reader :pellets

		def initialize(node_a, node_b)
			@node_a, @node_b = node_a, node_b
			clear_pellets!

			# Notify nodes of connectivity
			@node_a.add_neighbor(@node_b)
			@node_b.add_neighbor(@node_a)
			calculate!
		end

		def clear_pellets!
			@pellets = []
		end

		def calculate!
			@vector = (@node_b.position - @node_a.position)
			@length = @vector.length
			@angle = @vector.fuzzy_angle
			@center_point = (@node_a.position + @node_b.position) / 2.0
		end

		def hit?(point, radius)		# radius is half-width of the line
			a = point.x - @node_a.position.x
			b = point.y - @node_a.position.y
			c = @node_b.position.x - @node_a.position.x
			d = @node_b.position.y - @node_a.position.y
			distance = (a * d - c * b).abs / (c * c + d * d).square_root

			(distance <= radius) and (@center_point.distance_to_within?(point, (@length / 2.0)))
		end

		def has_node?(node)
			(@node_a == node or @node_b == node)
		end

		def has_nodes?(a, b)
			(@node_a == a and @node_b == b) or (@node_a == b and @node_b == a)
		end

		def add_pellet(p)
			@pellets << p
		end

		def remove_pellet(p)
			@pellets.delete(p)
		end
	end

	# Base class for "specials" that sit on nodes
	class MapObjectSpecial < MapObject
		def initialize(x, y, node)
			super
			@node.special = self #if @node.respond_to?(:special=)
		end
	end

	# Special Node that handles spatial transfereances of other types of MapObjects
	class Portal < MapObjectSpecial
		attr_accessor :number
		def initialize(number, x, y, node)
			super(x, y, node)
			@number = number
		end
	end

	# Special Node that provides spawn points for Hero's and enemis
	class Base < MapObjectSpecial
	end

	# Point based system for Hero's to collect while avoiding enemies when not power charged
	class Pellet < MapObject
		def initialize(x, y, path)
			@path = path
			@path.pellets << self
			super
		end
	end

	class PowerPellet < MapObjectSpecial
		boolean_accessor :used
	end

	#
	# Characters
	#
	class ControllableCharacter < MapObject
		attr_accessor :ai_mode

		def set_controls(x, y)
			vector = Vector3.new(x, y, 0.0)
			if vector.length > 0.0
				@input_angle = vector.fuzzy_angle
			else
				@input_angle = nil
			end
		end

		CHARACTER_ALLOWABLE_NODE_ANGLE_DEVIATION = 0.23		# less than 0.25, so right-key doesn't choose down-path
		CHARACTER_ALLOWABLE_PATH_ANGLE_DEVIATION = 0.23		# less than 0.25, so perpendicular-input doesn't flip directions every frame
		def choose_destination!
			choose_destination_by_input_angle!
		end

		def choose_destination_by_input_angle!
			return if @input_angle.nil?		# no movement unless direction chosen

			if @destination_node
				# The only thing player can do while on a path is reverse direction
				backward_angle = position.vector_to(@node.position).fuzzy_angle
				angle_difference = (@input_angle - backward_angle).abs % 1.0
				angle_difference = (1.0 - angle_difference) if angle_difference > 0.5
				@node, @destination_node = @destination_node, @node if angle_difference <= CHARACTER_ALLOWABLE_PATH_ANGLE_DEVIATION		# reverse!
			else
				# Choose best-matching neighbor node
				best_node = nil
				best_angle_difference = nil
				node.each_neighbor_with_fuzzy_angle { |node, angle|
					angle_difference = (@input_angle - angle).abs % 1.0
					angle_difference = (1.0 - angle_difference) if angle_difference > 0.5		# can't really be > 0.5 difference on a 0.0..1.0 circle!
					best_node, best_angle_difference = node, angle_difference if (best_angle_difference.nil? || (angle_difference < best_angle_difference))
				}
				@destination_node = best_node if (best_angle_difference && best_angle_difference <= CHARACTER_ALLOWABLE_NODE_ANGLE_DEVIATION)		# choose new destination
			end
		end
	end

	class Hero < ControllableCharacter
	end

	class Enemy < ControllableCharacter
		attr_accessor :map, :plugin		# hacks

		def find_nearest_hero
			best_hero = nil
			best_distance = nil
			@map.heroes.each { |hero|
				next if hero.exiting?
				distance = position.distance_squared_to(hero.position)		# no need for sqrt
				best_hero, best_distance = hero, distance if (best_distance.nil? or distance < best_distance)
			}
			return best_hero
		end

		def seek_ai
			if plugin.powerpellet_active?
				# Strategy: opposite direction of below strategy
				if(hero = @map.find_nearest_hero)
					@input_angle = hero.position.vector_to(position).fuzzy_angle
					choose_destination_by_input_angle!
				end
			else
				# Strategy: choose nearest hero and best direction to get to them
				if(hero = find_nearest_hero)
					@input_angle = position.vector_to(hero.position).fuzzy_angle
					choose_destination_by_input_angle!
				end
			end
		end

		def choose_destination!
			case ai_mode
			when :random
				return if @destination_node
				return choose_random_destination!
			when :seek
				return if @destination_node
				return seek_ai
			when :off
				super
			else
				raise "unhandled"
			end
		end
	end

	#
	# PacMap class
	#
	attr_accessor :nodes, :paths, :portals, :herobases, :enemybases,
								:heroes, :enemies, :pellets, :powerpellets, :floatingfruit

	NODE_SPECIALS = [:portals, :herobases, :enemybases, :powerpellets, :floatingfruit]

	def initialize
		@nodes, @paths, @portals, @herobases, @enemybases = [], [], [], [], []
		@pellets, @powerpellets, @heroes, @enemies, @floatingfruit = [], [], [], [], []

		#add_demo_data!
	end

	def find_node_by_special(special)
		@nodes.find { |node| node.special == special }
	end

	def each_array_of_specials
		NODE_SPECIALS.each { |sym| yield send(sym) }
	end

	def clean!
		each_array_of_specials { |array| array.delete_if { |special| find_node_by_special(special).nil? } }
	end

	def add_demo_data!
		@nodes << (a=Node.new(-0.25, 0.0))
		@nodes << (b=Node.new( 0.25, 0.0))

		# bases, portals
		@herobases << Base.new(@nodes.first.position.x, @nodes.first.position.y, @nodes.first)
		@enemybases << Base.new(@nodes.last.position.x, @nodes.last.position.y, @nodes.last)
	end

	def delete_node(node)
		@nodes.each { |n| n.remove_neighbor(node) }
		@paths.delete_if { |p| p.has_node?(node) }
		@nodes.delete(node)
		each_array_of_specials { |array| array.delete(node.special) } if node.special
	end

	def update_after_editing!
		@paths.each { |path| path.calculate! }
		each_node_special { |special| special.move_to_node! }
	end

	def each_node_special
		NODE_SPECIALS.each { |type| self.send(type).each { |obj| yield obj } }
	end

	def cycle_node_special!(node)
		if node.special.nil?
			@herobases << Base.new(node.position.x, node.position.y, node)
		elsif @herobases.delete(node.special)
			@enemybases << Base.new(node.position.x, node.position.y, node)
		elsif @enemybases.delete(node.special)
			@portals << Portal.new(find_next_free_portal_number, node.position.x, node.position.y, node)
		elsif @portals.delete(node.special)
			@powerpellets << PowerPellet.new(node.position.x, node.position.y, node)
		elsif @powerpellets.delete(node.special)
			node.special = nil
		else
			node.special = nil		# clear any wonkyness
		end
	end

	def find_next_free_portal_number
		(0..100).each { |i| return i unless @portals.count { |p| p.number == i } == 2 }
	end

	def other_portal(portal)
		@portals.find { |p| (p != portal) and (p.number == portal.number) }
	end

	#
	# Spawning
	#
	def spawn_hero!
		if (base = @herobases.random)
			@heroes << Hero.new(base.node.position.x, base.node.position.y, base.node)
			$engine.on_button_press('Game / Hero Spawn', 1)
		end
	end

	def spawn_enemy!(plugin, ai_mode)
		if (base = @enemybases.random)
			@enemies << (new_enemy=Enemy.new(base.node.position.x, base.node.position.y, base.node))
			new_enemy.ai_mode = ai_mode
			new_enemy.map = self
			new_enemy.plugin = plugin
			$engine.on_button_press('Game / Enemy Spawn', 1)
		end
	end

	def spawn_pellets!(pellet_spacing, node_size)
		@paths.each { |path|
			path.clear_pellets!
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
		$engine.on_button_press('Game / Pellets Spawn', 1) unless @pellets.empty?
	end

	def exit_characters!
		@heroes.each { |hero| hero.exit! }
		@enemies.each { |hero| hero.exit! }
	end

	def remove_characters!
		@heroes.clear
		@enemies.clear
	end

	#
	# Hit testing
	#
	def hit_test_nodes(point, node_size, not_node=nil)
		@nodes.find { |node|
			next if node == not_node
			(node.position.distance_to_within?(point, (node_size / 2)))
		}
	end

	def hit_test_paths(point, path_size)
		@paths.find { |path|
			path.hit?(point, path_size / 2)
		}
	end

	def find_path_by_nodes(node_a, node_b)
		@paths.find { |path| path.has_nodes?(node_a, node_b) }
	end
end

#
# Base level Director Effect plugin linking to pacmap game class: handles render, game tick, all game settings and parameter inputs
#
class DirectorEffectGamePacMap < DirectorEffect
	title				'PacMap'
	description 'PacMan, Luz-style.'

	include Drawing

	setting 'map_file_path', :string, :summary => true
	setting 'save_map', :event
	setting 'load_map', :event

	setting 'node', :actor
	setting 'node_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'path', :actor
	setting 'path_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'hero', :actor
	setting 'hero_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'hero_speed', :float, :range => 0.0..1.0, :default => 0.01..1.0
	setting 'hero_count', :integer, :range => 0..10, :default => 1..10
	setting 'hero_respawns', :integer, :range => 0..1000, :default => 0..10
	setting 'first_hero_input_variable', :variable

	setting 'enemy', :actor
	setting 'enemy_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'enemy_speed', :float, :range => 0.0..1.0, :default => 0.01..1.0
	setting 'enemy_count', :integer, :range => 0..10, :default => 1..10
	setting 'enemy_respawns', :integer, :range => 0..1000, :default => 0..10
	setting 'first_enemy_input_variable', :variable
	setting 'ai_mode', :select, :default => :off, :options => [[:off, 'Off'], [:random, 'Random'], [:seek, 'Seek']]

	setting 'pellet', :actor
	setting 'pellet_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'pellet_spacing', :float, :range => 0.001..1.0, :default => 0.03..1.0, :simple => true

	setting 'powerpellet', :actor
	setting 'powerpellet_size', :float, :range => 0.0..1.0, :default => 0.03..1.0
	setting 'powerpellet_time', :timespan, :default => [4, :seconds]

	setting 'floatingfruit', :actor
	setting 'floatingfruit_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'herobase', :actor
	setting 'herobase_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'enemybase', :actor
	setting 'enemybase_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'portal', :actor
	setting 'portal_size', :float, :range => 0.0..1.0, :default => 0.03..1.0

	setting 'character_angle_variable', :variable

	setting 'edit_x', :float, :range => -0.5..0.5, :default => -0.5..0.5
	setting 'edit_x', :float, :range => -0.5..0.5, :default => -0.5..0.5
	setting 'edit_y', :float, :range => -0.5..0.5, :default => -0.5..0.5
	setting 'edit_click', :event
	setting 'special_click', :event
	setting 'edit_crosshair', :actor
	setting 'edit_mode', :event

	DOUBLE_CLICK_TIME = 0.2

	def save_map!
		begin
			final_path = File.join($engine.project.file_path, map_file_path)
			puts "Saving map to '#{final_path}' ..."
			tmp_path = final_path + '.tmp'
			File.open(tmp_path, 'w+') { |tmp_file|
				tmp_file.write(ZAML.dump(@map))
				FileUtils.mv(tmp_path, final_path)
				return true
			}
		rescue Exception => e
			puts 'Map save failed:'
			e.report
		end
		return false
	end

	def load_map!
		begin
			final_path = File.join($engine.project.file_path, map_file_path)
			puts "Map loading from '#{final_path}'..."
			File.open(final_path) { |file|
				@map = YAML.load(file)
				@map.clean!
			}
		rescue Exception => e
			puts 'Map loading failed.'
			@map = PacMap.new		# clear Cloned map if map file is missing
		end
		@map ||= PacMap.new		# ensure some map is present
	end

	#
	# tick is called once per frame, before rendering
	#
	def tick
		unless @map
			load_map!
			start_pregame!
		end

		if edit_mode.now?
			end_game! if edit_mode.on_this_frame?		# End game upon entering edit mode
			save_map! if save_map.on_this_frame?		# Save and Load only work while in edit mode
			load_map! if load_map.on_this_frame?
			tick_edit_mode
		else
			tick_live_mode
		end
	end

	def tick_live_mode
		case @state
		when :pregame
			@countdown -= 1
			start_game! if @countdown == 0

		when :game
			game_tick!

		when :postgame
			@countdown -= 1
			start_pregame! if @countdown == 0

		else
			raise "unhandled game state #{@state}"
		end
	end

	def start_pregame!
		@map.remove_characters!
		@countdown = 80
		@state = :pregame
		$engine.on_button_press('Game / Pregame', 1)
		@powerpellet_time_remaining = 0.0
		$engine.on_slider_change('Game / Powerpellet Time', 0.0)
	end

	def start_game!
		@map.spawn_pellets!(pellet_spacing, node_size)
		@state = :game
		@hero_respawns_remaining = hero_respawns
		@enemy_respawns_remaining = enemy_respawns
		@map.powerpellets.each { |powerpellet| powerpellet.not_used! }
		$engine.on_button_press('Game / Start', 1)
	end

	def powerpellet_active?
		@powerpellet_time_remaining > 0.0
	end

	POWERPELLET_STEP_TIME = (1.0 / 30.0)
	def powerpellet_count_down!
		return if @powerpellet_time_remaining == 0.0
		if @powerpellet_time_remaining <= POWERPELLET_STEP_TIME
			@powerpellet_time_remaining = 0.0
			$engine.on_button_up('Game / Powerpellet')
		else
			@powerpellet_time_remaining -= POWERPELLET_STEP_TIME
		end
		$engine.on_slider_change('Game / Powerpellet Time', (@powerpellet_time_remaining / powerpellet_time.to_seconds))
	end

	def powerpellet!
		$engine.on_button_down('Game / Powerpellet', 1)
		@powerpellet_time_remaining = powerpellet_time.to_seconds
		$engine.on_slider_change('Game / Powerpellet Time', 1.0)
	end

	def update_character_inputs!
		first_index = $engine.project.variables.index(first_hero_input_variable_setting.variable)
		@map.heroes.each_with_index { |hero, index|
			x_variable, y_variable = $engine.project.variables[first_index + (index * 2)], $engine.project.variables[first_index + (index * 2) + 1]
			hero.set_controls(x_variable.value - 0.5, y_variable.value - 0.5) if x_variable and y_variable
		} if first_index

		first_index = $engine.project.variables.index(first_enemy_input_variable_setting.variable)
		@map.enemies.each_with_index { |enemy, index|
			x_variable, y_variable = $engine.project.variables[first_index + (index * 2)], $engine.project.variables[first_index + (index * 2) + 1]
			enemy.set_controls(x_variable.value - 0.5, y_variable.value - 0.5) if x_variable and y_variable
		} if first_index
	end

	def game_tick!
		# Spawn if needed
		if $env[:frame_number] % 10 == 0		# a delay between spawns so they don't all pile up
			@map.spawn_hero! if @map.heroes.size < hero_count
			@map.spawn_enemy!(self, ai_mode) if @map.enemies.size < enemy_count
		end

		update_character_inputs!
		tick_characters!

		powerpellet_count_down!

		# Heroes win?
		if @map.pellets.empty?
			$engine.on_button_press('Game / Hero Win', 1)
			end_game!
		end
	end

	def respawn_hero!(hero)
		if(base = @map.herobases.random)
			hero.warp_to(base.node)
			hero.reset_enter_exit!
		end
	end

	def respawn_enemy!(enemy)
		if(base = @map.enemybases.random)
			enemy.warp_to(base.node)
			enemy.reset_enter_exit!
		end
	end

	def tick_characters!
		hit_distance = (hero_size / 2)									# pellets are considered points for the purpose of collisions
		max_step_distance = hero_size										# this ensures complete hero hit coverage of the line
		steps = (hero_speed / max_step_distance).ceil		# speed is distance covered in one update

		active_hero = false
		@map.heroes.each { |hero|
			steps.times {
				hero.tick(hero_speed / steps)

				if hero.exiting?
					if hero.exited?
						# respawn?
						if @hero_respawns_remaining > 0
							respawn_hero!(hero)
							@hero_respawns_remaining -= 1
							active_hero = true
						end
					else
						active_hero = true
					end

				else
					active_hero = true

					# Heroes vs Pellets
					if (path = @map.find_path_by_nodes(hero.node, hero.destination_node))
						path.pellets.delete_if { |pellet|
							if hero.position.distance_to_within?(pellet.position, hit_distance) 
								@map.pellets.delete(pellet)
								$engine.on_button_press('Game / Pellet', 1)
								true
							end
						}
					end

					# Heroes vs PowerPellets
					@map.powerpellets.each { |powerpellet|
						if (!powerpellet.used?) and (hero.position.distance_to_within?(powerpellet.position, hit_distance))
							powerpellet.used!
							powerpellet!
						end
					}

					# Heroes vs Enemies
					@map.enemies.each { |enemy|
						if (!enemy.exiting?) and (hero.position.distance_to_within?(enemy.position, hit_distance))
							# Hit enemy
							if powerpellet_active?
								$engine.on_button_press('Game / Enemy Killed', 1)
								enemy.exit!
							else
								$engine.on_button_press('Game / Hero Killed', 1)
								hero.exit!
							end
						end
					}

					# Heroes vs Portals
					@map.portals.each { |portal|
						if (hero.destination_node == portal.node) and (hero.position.distance_to_within?(portal.position, hit_distance))
							if (other_portal = @map.other_portal(portal))
								$engine.on_button_press('Game / Hero Portal', 1)
								hero.warp_to(other_portal.node)
							end
						end
					}
				end
			}
		}

		# No more heroes?
		unless (active_hero or @map.heroes.empty?)
			$engine.on_button_press('Game / Enemy Win', 1)
			end_game!
		end

		@map.enemies.each { |enemy|
			enemy.tick(enemy_speed)

			if enemy.exited?
				# respawn?
				if (@enemy_respawns_remaining > 0) && (!powerpellet_active?)		# no enemy respawning while powerpellet active
					respawn_enemy!(enemy)
					@enemy_respawns_remaining -= 1
				end
			end

			# Enemies vs Portals
			@map.portals.each { |portal|
				if (enemy.destination_node == portal.node) and (enemy.position.distance_to_within?(portal.position, hit_distance))
					if (other_portal = @map.other_portal(portal))
						$engine.on_button_press('Game / Enemy Portal', 1)
						enemy.warp_to(other_portal.node)
					end
				end
			}
		}
	end

	def end_game!
		@map.exit_characters!
		@map.pellets.clear
		@countdown = 80		# TODO: time based?
		@state = :postgame
	end

	#
	# render is responsible for all drawing, and must yield to continue down the effects list
	#
	def render
		render_map_lower
		render_characters unless edit_mode.now?
		render_map_upper
		render_edit_controls if edit_mode.now?

		yield
	end

	def render_map_lower
		# Paths
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

		# Nodes
		render_list_via_offscreen_buffer(@map.nodes, node_size, :medium) {
			node.render!
		}

		# PowerPellets
		@map.powerpellets.each_with_index { |p, i|
			next if p.used?
			with_character_setup(p, powerpellet_size, i) {
				powerpellet.render!
			}
		}
	end

	def render_map_upper
		# Hero Base
		render_list_via_offscreen_buffer(@map.herobases, herobase_size, :medium) {
			herobase.render!
		}

		# Enemy Base
		render_list_via_offscreen_buffer(@map.enemybases, enemybase_size, :medium) {
			enemybase.render!
		}

		# Portals
		@map.portals.each_with_index { |p, i|
			with_character_setup(p, portal_size, p.number) {
				portal.render!
			}
		}
	end

	def render_characters
		# Pellets
		render_list_via_offscreen_buffer(@map.pellets, pellet_size, :small) {
			pellet.render!
		}

=begin
		# Floating Fruit
		render_list_via_offscreen_buffer(@map.floatingfruits, floatingfruit_size, :small) {
			floatingfruit.render!
		}
=end

		# Heros
		@map.heroes.each_with_index { |h, i|
			with_character_setup(h, hero_size, i) {
				hero.render!
			}
		}

		# Enemies
		@map.enemies.each_with_index { |e, i|
			with_character_setup(e, enemy_size, i) {
				enemy.render!
			}
		}
	end

	def render_edit_controls
		with_translation(edit_x, edit_y) {
			edit_crosshair.render!
		}
	end

	#
	# render helpers
	#
	def render_list_via_offscreen_buffer(characters, size, buffer_size)
		with_offscreen_buffer(buffer_size) { |buffer|
			# Render once into offscreen buffer (caller is responsible for actual rendering)
			buffer.using {
				yield
			}
			# Render a rectangle for each character using above buffer as texture
			buffer.with_image {
				characters.each { |character|
					with_translation(character.position.x, character.position.y) {
						with_scale(size, size, size) {
							unit_square
						}
					}
				}
			}
		}
	end

	# setup global state, position and scale for rendering actor
	def with_character_setup(character, size, index)
		character.with_enter_and_exit_for_actor {
			with_env(:child_index, index) {
				character_angle_variable_setting.with_value(character.angle) {
					with_translation(character.position.x, character.position.y) {
						with_scale(size, size, size) {
							yield
						}
					}
				}
			}
		}
	end

	#
	# Live-editing methods
	#
	def tick_edit_mode
		point = Vector3.new(edit_x, edit_y, 0.0)

		if edit_click.on_this_frame?		# newly down?
			# double click?
			if (@edit_click_time and (($env[:frame_time] - @edit_click_time) <= DOUBLE_CLICK_TIME))
				handle_double_click(point)
			else
				@edit_selection = @map.hit_test_nodes(point, node_size)
				@edit_selection_offset = (@edit_selection.position - point) if @edit_selection
				@edit_click_time = $env[:frame_time]
			end

		elsif edit_click.now?		# still down?
			handle_editing_drag(point) if @edit_selection

		else
			handle_editing_drop(point) if @edit_selection
			@edit_selection = nil
		end

		if special_click.on_this_frame?
			# double special click?
			if (@edit_click_time and (($env[:frame_time] - @edit_click_time) <= DOUBLE_CLICK_TIME))
				if (hit_path = @map.hit_test_paths(point, path_size))
					@map.paths.delete(hit_path)

					# each side loses a neighbor
					hit_path.node_a.remove_neighbor(hit_path.node_b)
					hit_path.node_b.remove_neighbor(hit_path.node_a)
				end
			else
				if (node = @map.hit_test_nodes(point, node_size))
					@map.cycle_node_special!(node)
				else
					@edit_click_time = $env[:frame_time]
				end
			end
		end
	end

	def handle_double_click(point)
		new_node = nil

		# test hit nodes first, since they're drawn above paths
		if (hit_node = @map.hit_test_nodes(point, node_size))
			# double-clicking a node creates a new node and new path, connected to clicked node
			new_node = PacMap::Node.new(point.x, point.y)
			@map.nodes << new_node
			@map.paths << PacMap::Path.new(hit_node, new_node)
			# NOTE: set as the @edit_selection below

		elsif (hit_path = @map.hit_test_paths(point, path_size))
			# double-clicking a path splits it with a new node

			# each side loses a neighbor
			hit_path.node_a.remove_neighbor(hit_path.node_b)
			hit_path.node_b.remove_neighbor(hit_path.node_a)

			# bisect path with a new node
			new_node = PacMap::Node.new(point.x, point.y)
			@map.paths << PacMap::Path.new(hit_path.node_a, new_node)
			@map.paths << PacMap::Path.new(new_node, hit_path.node_b)
			@map.paths.delete(hit_path)
			@map.nodes << new_node

		else
			# double-clicking empty space creates a new unattached node
			new_node = PacMap::Node.new(point.x, point.y)
			@map.nodes << new_node
		end

		# Auto-select new node
		@edit_selection = new_node
		@edit_selection_offset = Vector3.new(0.0, 0.0, 0.0)
	end

	def handle_editing_drag(point)
		point_with_offset = point + @edit_selection_offset
		@edit_selection.position.set(point_with_offset.x, point_with_offset.y, 0.0)
		@map.update_after_editing!
	end

	def handle_editing_drop(point)
		node = @map.hit_test_nodes(point, node_size, not_node=@edit_selection)
		return unless node

		# node gets all of @edit_selection's neighbors
		@edit_selection.each_neighbor { |neighbor_node|
			if @map.find_path_by_nodes(neighbor_node, node)
				neighbor_node.add_neighbor(node)
				node.add_neighbor(neighbor_node)
			else
				@map.paths << PacMap::Path.new(neighbor_node, node)
			end
		}
		@map.delete_node(@edit_selection)
	end
end
