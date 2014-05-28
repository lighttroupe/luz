# Mixin: Taggable.
#
# IMPORTANT: This mixin MUST be included in your class BEFORE inheriting from your class.
# IMPORTANT: Any self.inherited method in your class MUST call 'super'.
#
# A typical and safe use is as follows:
#
#  class MyClass
#    include Taggable
#    ...
#    self.inherited(klass)
#      ...
#      super
#    end
#    ...
#  end
#
# At the class level, we have one data structure:
#  @objects_with_tag['sometag'] => [obj, obj, obj]
#
# This makes for a fast MyClass.with_tag('some_tag'), which we consider the most speed-critical class-level method.
#
# At the object instance level, we have one data structure:
#  @tags['sometag'] => true
#
# This makes for a fast my_object.has_tag?('some_tag'), which we consider the most speed-critical instance-level method.

module Taggable
	def self.included(base) #:nodoc:
		base.extend(ClassMethods)

		# Each time this module is included, create a new class-level @objects_with_tag variable.
		base.objects_with_tag = Hash.new

		# The class that did the 'include Taggable'
		base.instance_variable_set('@taggable_base_class', base)

		# Each time our base class is inherited, give the new class a class-level @objects_with_tag variable that points to the base's version.
		# In other words, Shape, ShapeRectangle, ShapeCircle all share one @objects_with_tag hash, but Shape and Animal do not.
		base.class_eval {
			def self.inherited(klass)
				# NOTE: This DOES properly handle multiple levels of inheritence.  Remember that children are always created before grandchildren.
				klass.instance_variable_set('@objects_with_tag', klass.superclass.instance_variable_get('@objects_with_tag'))
				klass.instance_variable_set('@taggable_base_class', klass.superclass.instance_variable_get('@taggable_base_class'))
				super
			end
		}
	end

	###################################################################
	# Class-level methods
	###################################################################

	module ClassMethods
		# FOR INTERNAL USE ONLY by self.included above.  Users of Taggable should use self.with_tag or self.tags instead.
		attr_accessor :objects_with_tag

		# Externally readable.  To continue the example from above, ShapeCircle.taggable_base_class => Shape
		attr_reader :taggable_base_class

		# Returns array of objects tagged with given tag.
		# Objects are instances of the class that did 'include Taggable' or any subclass of that class.
		def with_tag(tag)
			return @objects_with_tag[tag] || []
		end

		# Returns array of all unique keys used by instances of the class that did 'include Taggable' + subclasses.
		def tags
			return @objects_with_tag.keys
		end

		# FOR INTERNAL USE ONLY.  Called by instance-level methods to add 'object' to the list of objects tagged with 'tag'.
		def add_object_with_tag(object, tag)
			@objects_with_tag[tag] ||= []
			@objects_with_tag[tag] << object unless @objects_with_tag[tag].include?(object)
		end

		# FOR INTERNAL USE ONLY.  Called by instance-level methods to remove 'object' from the list of objects tagged with 'tag'.
		def remove_object_with_tag(object, tag)
			array = @objects_with_tag[tag]
			if array
				array.delete(object)
				@objects_with_tag.delete(tag) if array.empty?
			end
		end

		# offer caller a way to set the order of with_tag() objects
		def sort_tagged_objects(&proc)
			@objects_with_tag.each_pair { |key, array| array.sort!(&proc) }
		end

		def swap_tagged_objects(tag, object_a, object_b)
			list = @objects_with_tag[tag]
			return unless list
			index_a, index_b = list.index(object_a), list.index(object_b)
			list[index_a], list[index_b] = list[index_b], list[index_a]
		end
	end

	###################################################################
	# Object-level methods
	###################################################################

	# Add a single tag.
	def add_tag(tag)
		@tags ||= {}
		if @tags[tag].nil?
			# Add to object's list of tags.
			@tags[tag] = true

			# Add to class-level list of tags.
			self.class.add_object_with_tag(self, tag)
		end
		return self
	end

	# Add multiple tags.
	def add_tags(tags)
		# Support passing of non-array argument
		return add_tag(tags) unless tags.is_a? Array

		# Handle array.
		tags.each { |tag| add_tag(tag) }
		return self
	end

	# Replace tags with given array of tags.
	def tags=(new_tags)
		current_tags = self.tags

		# Add tags that we don't yet have
		(new_tags - current_tags).each { |tag| add_tag(tag) }

		# Remove existing tags that don't exist in new_tags
		(current_tags - new_tags).each { |tag| remove_tag(tag) }
	end

	# Returns list of tags on this instance.
	def tags
		return (@tags || {}).keys
	end

	# Yields each tag on this instance, one at a time.
	def tag_each
		tags.each { |tag| yield tag }
		return self
	end

	# Returns true if this instance is tagged with the given tag, otherwise false.
	def has_tag?(tag)
		return false unless @tags
		return @tags.has_key?(tag)
	end

	def num_tags
		(@tags || {}).size
	end

	# Removes a single tag from this instance.
	def remove_tag(tag)
		@tags.delete(tag) if @tags
		self.class.remove_object_with_tag(self, tag)
		return self
	end

	# Removes all tags on this instance.  Returns self.
	def clear_tags
		if @tags
			@tags.each { |tag, __unused| self.class.remove_object_with_tag(self, tag) }
			@tags.clear
		end
		return self
	end

	def after_load_tag_class_registration
		@tags.each { |tag, __unused| self.class.add_object_with_tag(self, tag) } if @tags
	end

	def tag_instance_variables
		['@tags']
	end
end

if $0 == __FILE__
	require 'test/unit'

	class TestTaggable < Test::Unit::TestCase
		# NOTE: all tests must leave objects untagged, so as not to interfere with other class-level tests

		class Base
		end

		class A < Base
			include Taggable
		end

		class AA < A
		end

		class AB < A
		end

		class B < Base
			include Taggable
		end

		def test_add_and_remove_string_tags
			a = A.new

			# None
			assert_equal false, a.has_tag?('one')
			assert_equal 0, a.num_tags

			# Add Single
			a.add_tag('one')
			assert_equal true, a.has_tag?('one')
			assert_equal 1, a.num_tags

			# Add Multiple
			a.add_tags(['two', 'three'])
			assert_equal true, a.has_tag?('one')
			assert_equal true, a.has_tag?('two')
			assert_equal true, a.has_tag?('three')
			assert_equal 3, a.num_tags

			# Remove
			a.remove_tag('one')
			assert_equal false, a.has_tag?('one')
			assert_equal true, a.has_tag?('two')
			assert_equal true, a.has_tag?('three')
			assert_equal 2, a.num_tags

			# Clear
			a.clear_tags
			assert_equal false, a.has_tag?('one')
			assert_equal false, a.has_tag?('two')
			assert_equal false, a.has_tag?('three')
			assert_equal 0, a.num_tags

			# Mass-assign
			a.tags = ['one', 'two', 'three']
			assert_equal true, a.has_tag?('one')
			assert_equal true, a.has_tag?('two')
			assert_equal true, a.has_tag?('three')
			assert_equal 3, a.num_tags

			# Mass-re-assign
			a.tags = ['two', 'three', 'four']
			assert_equal false, a.has_tag?('one')
			assert_equal true, a.has_tag?('two')
			assert_equal true, a.has_tag?('three')
			assert_equal true, a.has_tag?('four')
			assert_equal 3, a.num_tags

			# Mass-retrieve (via 'tags' method)
			a.clear_tags
			a.tags = ['one', 'two', 'three']
			assert_equal 3, a.tags.size
			assert_equal true, a.tags.include?('one')
			assert_equal true, a.tags.include?('two')
			assert_equal true, a.tags.include?('three')

			# Iteration
			a.tag_each { |tag|
				assert_equal true, ['one', 'two', 'three'].include?(tag)
			}

			a.clear_tags
		end

		def test_add_and_remove_symbol_tags
			a = A.new

			# None
			assert_equal false, a.has_tag?(:one)
			assert_equal 0, a.num_tags

			# Add Single
			a.add_tag(:one)
			assert_equal true, a.has_tag?(:one)
			assert_equal 1, a.num_tags

			# NOTE: Can't mix strings and symbols.  Choose one!
			assert_equal false, a.has_tag?('one')

			# Remove
			a.remove_tag(:one)
			assert_equal false, a.has_tag?(:one)
			assert_equal 0, a.num_tags
		end

		def test_remove_unknown
			a = A.new

			a.add_tag('one')
			a.remove_tag('unknown')
			assert_equal true, a.has_tag?('one')
			assert_equal false, a.has_tag?('unknown')
			assert_equal 1, a.num_tags

			a.clear_tags
		end

		def test_cross_object_contamination
			a1 = A.new
			a2 = A.new

			# Tag a1
			a1.add_tag('one')
			assert_equal 1, a1.num_tags
			assert_equal 0, a2.num_tags

			# Tag a2
			a2.add_tag('two')
			assert_equal 1, a1.num_tags
			assert_equal 1, a2.num_tags

			# Each has correct tag
			assert_equal true, a1.has_tag?('one')
			assert_equal false, a1.has_tag?('two')
			assert_equal false, a2.has_tag?('one')
			assert_equal true, a2.has_tag?('two')

			a1.clear_tags
			a2.clear_tags
		end

		def test_class_level_tags
			a1 = A.new
			a2 = A.new
			a3 = A.new

			# Find objects with tag
			a1.add_tag('one')
			assert_equal 1, A.with_tag('one').size
			assert_equal a1, A.with_tag('one').first

			# Add another
			a2.add_tag('one')
			assert_equal 2, A.with_tag('one').size
			assert_equal true, A.with_tag('one').include?(a1)
			assert_equal true, A.with_tag('one').include?(a2)

			# False remove (no change)
			a2.remove_tag('unknown')
			assert_equal 2, A.with_tag('one').size
			assert_equal true, A.with_tag('one').include?(a1)
			assert_equal true, A.with_tag('one').include?(a2)

			# Remove one
			a1.clear_tags
			assert_equal 1, A.with_tag('one').size
			assert_equal a2, A.with_tag('one').first

			a1.clear_tags
			a2.clear_tags
			a3.clear_tags
		end

		def test_class_level_contamination
			a = A.new
			b = B.new

			# Tag 'a'
			a.add_tag('one')
			assert_equal 1, A.with_tag('one').size
			assert_equal a, A.with_tag('one').first
			assert_equal 0, B.with_tag('one').size

			# Tag 'b' the same way
			b.add_tag('one')
			assert_equal 1, A.with_tag('one').size
			assert_equal a, A.with_tag('one').first
			assert_equal 1, B.with_tag('one').size
			assert_equal b, B.with_tag('one').first

			a.clear_tags
			b.clear_tags
		end

		def test_subclasses_share_tags
			aa = AA.new
			ab = AB.new

			# Tags on 'aa' should count towards A
			aa.add_tag('one')
			assert_equal 1, A.with_tag('one').size

			# Tags on 'ab' should also count towards A
			ab.add_tag('one')
			assert_equal 2, A.with_tag('one').size

			# Note that Class::with_tag on a child of the parent class (the one that
			# included Taggable) will report the same as the parent.
			assert_equal 2, AA.with_tag('one').size
			assert_equal 2, AB.with_tag('one').size

			aa.clear_tags
			assert_equal 1, A.with_tag('one').size

			ab.clear_tags
			assert_equal 0, A.with_tag('one').size
		end
	end
end
