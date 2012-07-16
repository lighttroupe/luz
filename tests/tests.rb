#!/usr/bin/ruby
$LOAD_PATH << '/usr/lib/ruby/1.9.1/i486-linux/'

Dir.chdir(File.dirname(__FILE__))	# So that this file can be run from anywhere

APP_NAME = 'Luz Director Tests'

$visual_output = true unless ARGV[0] == '--headless'

#require 'test/unit'

Dir.chdir('..')
$LOAD_PATH.unshift('./utils').unshift('.')
$LOAD_PATH << './user-object-settings'
$LOAD_PATH << './engine'

require 'reloadable_require'
require 'addons_ruby', 'method_piping', 'boolean_accessor'
require 'constants', 'sdl', 'opengl', 'addons_gl', 'drawing'

TESTS_PATH = 'tests'		# relative to root
TEST_FRAME_LIMIT = 400
FRAME_TO_START_ON = 3		# tests cannot pass before this frame, and it triggers a "Test / Start" button press (2 causes problems with frame_number==1 hack in on_button_down, so >2)

$settings = {}

#
# Prepare Output Window
#
if $visual_output
	include Drawing

	require 'sdl'
	SDL.init(SDL::INIT_VIDEO | SDL::INIT_TIMER)
	puts "Using SDL version #{SDL::VERSION}"
	screen = SDL.set_video_mode(300, 200, bpp=32, SDL::HWSURFACE | SDL::OPENGL)

	SDL::WM.set_caption(APP_NAME, '')
	GL.Viewport(0, 0, screen.w, screen.h)

	clear_screen([1.0, 0.0, 0.0, 1.0])
end

#
# Load Engine
#
require 'engine'
$engine = Engine.new
$engine.post_initialize
$engine.load_plugins
$engine.on_user_object_exception { |obj, e| puts e.report_format }
$engine.on_render { $engine.render(enable_frame_saving=true) }		# NOTE: We just have one global context, so this renders to it
$engine.load_from_path(File.join(TESTS_PATH, 'tests.luz'))
$test_pass_event, $test_fail_event, $next_test_event = find_event_by_name('test pass'), find_event_by_name('test fail'), find_event_by_name('next test!')

def assert(value, message=nil)
	raise(RuntimeError, "assert failed: #{message}", caller) unless value
end

def assert_equal(a, b, message=nil)
	raise(RuntimeError, "assert failed #{a} != #{b}: \"#{message}\"", caller) unless a == b
end
require 'garbage_counter'
def test_directors
	time = 0.0
	$engine.project.directors.count.times { |director_index|
		passed, failed = false, false
		director_name = $engine.project.directors[director_index].title
		puts "Loading director '#{director_name}'..."

		(1..TEST_FRAME_LIMIT).each { |frame_count|
			if frame_count == FRAME_TO_START_ON
				$engine.on_button_press('Test / Start', 1)
			end

			time += (1.0/30.0)
			$engine.do_frame(time)
			SDL.GL_swap_buffers if $visual_output

			#
			# Check events to see if a trigger on-touch etc. happened for pass/fail
			#
			if $test_fail_event.now?
				assert(false, "director '#{director_name}' index #{$next_test_event.count} failed on frame #{frame_count}")
				failed = true
				break
			end

			if $test_pass_event.now?
				if frame_count <= FRAME_TO_START_ON
					# Passing too soon is failure
					assert(false, "director '#{director_name}' index #{$next_test_event.count} passed on frame #{frame_count} which is not allowed")
					failed = true
				else
					puts "director '#{director_name}' index #{$next_test_event.count} passed on frame #{frame_count}"
					passed = true
				end
				break
			end
		}

		# Did it pass TOO SOON?
		assert(false, "director '#{director_name}' index #{$next_test_event.count} failed because it ran out of time") unless (passed or failed)

		$engine.on_button_press('Test / Next', 1)

		# Do a frame to eat all last-frame button presses so they don't affect next test
		$engine.do_frame(time)

		assert(true)		# we deserve it!
	}
	assert_equal(0, $test_fail_event.count, "test fail count")
end

begin
	test_directors
rescue RuntimeError => e
	puts "=========================================="
	puts "= The following error occurred:"
	puts "=  #{e.message}"
	puts "=========================================="
	sleep
end
