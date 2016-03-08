require_relative 'assertions.rb'

module Contract
	include Assertions

	# def invariant(list_to_sort, comparator)
	# 	assert(list_to_sort.kind_of?(Array), 
	# 		"objects to sort must be stored in Array", :TypeError)
	# 	assert(list_to_sort.length > 0, 
	# 		"no valid objects to sort", :RangeError)
	# 	assert(list_to_sort.all? {|i| i.is_a?(@list_to_sort[0].class) }, 
	# 		"all elements must be of same type", :TypeError)
	# 	# ^^ http://stackoverflow.com/questions/12158954/can-i-check-if-an-array-e-g-just-holds-integers-in-ruby
	# 	# answered by Sergio Tulentsev on Aug 28 '12 at 12:14
	# 	assert(comparator.is_a?(Proc), "Comparator must be callable as a proc.", :RuntimeError)
	# end

	def pre_sort(duration_)
		assert(duration_.is_a?(Numeric), "Invalid duration - should be a number.", :ArgumentError)
		assert(duration_ > 0, "Must have positive duration.", :ArgumentError)
	end
	# def pre_initialize(*args)
	# 	assert(args.size > 0, "Cannot have zero elements to sort", :ArgumentError)
	# end

	# def post_initialize(list_to_sort, comparator)
	# 	list_to_sort.each_with_index do |obj, index|
	# 		assert(!comparator.call(obj, list_to_sort[i-1]).nil?, "Objects must be comparable.", :RuntimeError)
	# 	end
	# end

	# def pre_define_comparator(comparator)
	# 	assert(comparator.is_a?(Proc), "Invalid comparator.", :TypeError)
	# end

	# def post_define_comparator
	# end

	def post_sort(sorted_list, comparator)
		(0..sorted_list.length - 2).step(1) { |i|
			assert(comparator.call(sorted_list[i], sorted_list[i+1]) < 1, "List is not sorted.", :RuntimeError)
		}
	end

	def pre_parallel_merge_sort(a, p, r)
		assert(a.is_a?(Array), "Must be sorting an array.", :ArgumentError)
		assert(a.length > 0, 
			"no valid objects to sort", :RangeError)
		assert(a.all? {|i| i.is_a?(a[0].class) }, 
			"all elements must be of same type", :TypeError)
		assert(p.is_a?(Numeric), "Index p must be a number.", :ArgumentError)
		assert(r.is_a?(Numeric), "Index r must be a number.", :ArgumentError)
		assert(p.between?(0, a.size), "Index p out of bounds.", :KeyError)
		assert(r.between?(0, a.size), "Indes r out of bounds.", :KeyError)
	end

	# def post_parallel_merge_sort(sorted_list)
	# 	sorted_list.size.times { |i|
	# 		while(i < sorted_list.size-1) do
	# 			assert(sorted_list[i] <= sorted_list[i+1], "List is not sorted.", :RuntimeError)
	# 		end
	# 	}
	# end

	def pre_parallel_merge(left, right, list_to_sort, start_index)
		assert(left.is_a?(Array), "Left partition must be an array.")
		assert(right.is_a?(Array), "Right partition must be an array.")
		assert(start_index.is_a?(Numeric), "Start index must be a number.")
		assert(start_index >= 0, "Start index cannot be less than 0.", :KeyError)
	end

	def post_parallel_merge
	end

	# def pre_new_list(objects)
	# 	assert(objects.size > 0, "Cannot have zero elements to sort", :ArgumentError)
	# end

	# def post_new_list(list_to_sort, comparator)
	# 	list_to_sort.each_with_index do |obj, index|
	# 		assert(!comparator.call(obj, list_to_sort[index-1]).nil?, "Objects must be comparable.", :RuntimeError)
	# 	end
	# end

end

=begin
	def pre_parse_file(filename, extensions)
		assert(filename =~ /.+(#{extensions.keys.join("|")})/, "invalid specification of filename")
	end

	def post_parse_file
		# nothing to check
	end

	def pre_sort
		# nothing to check
	end

	def post_sort(list_to_sort, result)
		assert(result.length == list_to_sort.length, 
			"sorting a list should not change its length", :RangeError)
		assert(
			list_to_sort.each_with_object(Hash.new(0)) { |obj,counts| counts[obj] += 1 } == 
			result.each_with_object(Hash.new(0)) { |obj,counts| counts[obj] += 1 },
			"Should be the same amount of each object after sorting as before sorting",
			:TypeError)
		assert(result.each_cons(2).all? { |a, b| (a <=> b) != 1 }, 
			"elements must be in sorted order", :RangeError)
		# ^^ http://stackoverflow.com/questions/8015775/check-to-see-if-an-array-is-already-sorted
		# answered by Marc-André Lafortune on Nov 4 '11 at 21:34

	end

	def pre_merge_sort(list_to_sort)
		# nothing to check
	end

	def post_merge_sort
		# nothing to check
	end

	def pre_merge(left, right)
		# nothing to check
	end

	def post_merge
		# nothing to check
	end

end

=end
