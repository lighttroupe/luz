###############################################################################
#  Copyright 2011 Ian McIntosh <ian@openanswers.org>
###############################################################################

# Helpers to render solid / wire spheres of radius 0.5 and reasonable detail
def render_solid_sphere
	$solid_sphere_list ||= GL.RenderToList { GLUT.SolidSphere(0.5, 10, 10) }
	GL.CallList($solid_sphere_list)
end

def render_wire_sphere
	$wire_sphere_list ||= GL.RenderToList { GLUT.WireSphere(0.5, 10, 10) }
	GL.CallList($wire_sphere_list)
end

R = 0.5
CUBE_VERTICES = [[-R,-R,-R],[-R,R,-R],[R,R,-R],[R,-R,-R],[-R,-R,R],[-R,R,R],[R,R,R],[R,-R,R],[-R,-R,-R],[-R,R,-R],[-R,R,R],[-R,-R,R],[R,-R,-R],[R,R,-R],[R,R,R],[R,-R,R],[-R,-R,-R],[R,-R,-R],[R,-R,R],[-R,-R,R],[-R,R,-R],[R,R,-R],[R,R,R],[-R,R,R]]
def render_cube
	$cube_list ||= GL.RenderToList { GL.Begin(GL::QUADS) ; CUBE_VERTICES.each { |a| GL.Vertex(a[0], a[1], a[2]) } ; GL.End }
	GL.CallList($cube_list)
end

class Array3D
	attr_reader :size_x, :size_y, :size_z
	attr_accessor :wrap

	def initialize(size_x, size_y, size_z, &element_creation_proc)
		@size_x, @size_y, @size_z = size_x, size_y, size_z
		@array = Array.new(@size_x) { Array.new(@size_y) { Array.new(@size_z) { element_creation_proc.call }}}
		@wrap = true
	end

	def at(x, y, z)
		if wrap
			x %= @size_x
			y %= @size_y
			z %= @size_z
			@array[x][y][z]
		else
			(a=@array[x]) && (b=a[y]) && b[z]
		end
	end

	def each_with_indices
		(0...@size_z).each { |z|		# Z first to make rendering easier
			(0...@size_y).each { |y|
				(0...@size_x).each { |x|
					yield at(x, y, z), x, y, z
				}
			}
		}
	end
end

class Automaton
	include Drawing
	attr_accessor :on

# oscillator
#	BIRTH = [4,6,7]
#	SURVIVAL = [2]

# space invader (14x14x2)
#	BIRTH = [3]
#	SURVIVAL = [5,6,7,8]

# glider (14x14x3)
#	BIRTH = [6]
#	SURVIVAL = [5,6,7]

	BIRTH = [0,1]
	SURVIVAL = (9..25).to_a

	ON_COLOR = [1,1,1,0.7]
	OFF_COLOR = [1,0,0,0.1]

	def initialize
		@on = false
		@new_state = false
		@count = 0
	end

	def neighbors_alive(proc)
		sum = 0
		(-1..1).each {|x| (-1..1).each { |y| (-1..1).each { |z| sum += (((a=proc.call(x,y,z)) && a.on) ? 1 : 0) unless x==0 and y==0 and z==0 }}}
		return sum
	end

	def tick(&neighbor_proc)
		neighbors = neighbors_alive(neighbor_proc)
		@new_state = (@on ? SURVIVAL.include?(neighbors) : BIRTH.include?(neighbors))
		@count = (@on && @new_state) ? @count + 1 : ((@new_state) ? 1 : 0)
	end

	def render(x,y,z)
		if @new_state
			with_color([1.0, 1.0 - @count * 0.1, 1.0 - @count * 0.1, z*0.2]) {
				#render_solid_sphere
				#render_wire_sphere
				c = (@count * 0.1).clamp(0.0,1.0)
				with_translation(rand * 0.05 * c, rand * 0.05 * c, rand * 0.05 * c) {
					render_cube
				}
			}
		else

			with_color(OFF_COLOR) {
				with_scale(0.2, 0.2, 0.2) {
					render_cube
					#render_solid_sphere
				}
			}

		end
	end
	
	def post_tick
		@on = @new_state
	end
end

=begin
	def average_of_neighbors(channel, proc)
		sum = 0.0
		(-1..1).each {|x| (-1..1).each { |y| (-1..1).each { |z| sum += proc.call(x,y,z).send(channel) unless x==0 and y==0 and z==0 }}}
		return sum / 26.0
	end
=end

class DirectorEffectLife < DirectorEffect
	title 'Life'
	description 'In Ruby form.'

	setting 'reload', :event
	setting 'automaton_scale', :float, :range => 0.1..2.0, :default => 1.0..2.0
	setting 'size_x', :integer, :range => 1..100, :default => 10..20
	setting 'size_y', :integer, :range => 1..100, :default => 10..20
	setting 'size_z', :integer, :range => 1..100, :default => 10..20
	#setting 'update_every', :integer, :range => 1..100, :default => 1..20
	setting 'update', :event

	#
	# after_load is called once when object is first created, and also after an engine reload
	#
	def after_load
		do_reload
		super
	end

	def do_reload
		puts "Reloading #{title}"
		@array = nil
		$solid_sphere_list = nil
		$wire_sphere_list = nil
		$cube_list = nil
	end

	def init_array
		@array = Array3D.new(size_x, size_y, size_z) { Automaton.new }

# corresponds to oscillators and invaders above 
#=begin
		@array.at(0, 0, 0).on = true
		@array.at(0, 0, 1).on = true
		@array.at(0, 1, 0).on = true
		@array.at(0, 1, 0).on = true
		@array.at(0, 1, 1).on = true
		@array.at(0, 1, 2).on = true
#=end

=begin
		[[0, 0, 0],[-1, 0, 0]].each { |a|
			@array.at(a[0], a[1], a[2]).on = true
		}
=end

=begin
		# glider
		@array.at(7, 7, 0).on = true
		@array.at(6, 7, 0).on = true
		@array.at(8, 7, 0).on = true
		@array.at(8, 8, 0).on = true
		@array.at(7, 9, 0).on = true
		@array.at(7, 7, 1).on = true
		@array.at(6, 7, 1).on = true
		@array.at(8, 7, 1).on = true
		@array.at(8, 8, 1).on = true
		@array.at(7, 9, 1).on = true
=end
	end

	#
	# tick is called once per frame, before rendering
	#
	def tick
		# Lazy reloading
		do_reload if (reload.now?)
		init_array unless @array

		@array.each_with_indices { |automaton, x, y, z|
			automaton.tick { |dx, dy, dz|
				@array.at(x+dx, y+dy, z+dz)
			}
		} if update.now?
	end

	def render
		with_scale(0.5, 0.5, 0.5) {
			@array.each_with_indices { |automaton, x, y, z|
				# Position and Scale Automaton
				with_translation(x - @array.size_x/2.0, y - @array.size_y/2.0, z - @array.size_z/2.0){
					with_scale(automaton_scale, automaton_scale, automaton_scale) {
						automaton.render(x,y,z)
					}
				}
				automaton.post_tick if update.now?
			}
		}
		yield		# must yield to continue down the Director Effects list
	end
end
