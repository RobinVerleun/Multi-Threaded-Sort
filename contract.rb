require_relative 'assertions.rb'

module Contract
	include Assertions

	def invariant(list_to_sort)
		assert(list_to_sort.kind_of?(Array), 
			"objects to sort must be stored in Array", :TypeError)
		assert(list_to_sort.length > 0, 
			"no valid objects to sort", :RangeError)
		assert(list_to_sort.all? {|i| i.is_a?(@list_to_sort[0].class) }, 
			"all elements must be of same type", :TypeError)
		# ^^ http://stackoverflow.com/questions/12158954/can-i-check-if-an-array-e-g-just-holds-integers-in-ruby
		# answered by Sergio Tulentsev on Aug 28 '12 at 12:14
		assert(list_to_sort.all? {|i| i.respond_to?("<=>") }, 
			"all elements must be comparable", :NoMethodError)
	end

	def pre_initialize(*args)
		assert(args.length >= 2, "must provide duration and objects, or duration and a file")
		assert(is_number?(args[0]), "must provide numeric duration")
		assert(args[0].to_i > 0, "duration must be positive", :RangeError)
	end

	def post_initialize(list_to_sort)
		# confirmed by invariant
	end

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