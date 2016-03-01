require_relative 'assertions.rb'

module Contract
	include Assertions

	def invariant
		
	end

	def pre_initialize(*args)
		assert(args.length >= 2, "must provide duration and objects, or duration and a file")
		assert(is_number?(args[0]), "must provide numeric duration")
	end

	def post_initialize(list_to_sort)
		assert(list_to_sort.kind_of?(Array), "array of objects to sort not present")
		assert(list_to_sort.length > 0, "no valid objects to sort")

		list_to_sort.each do |item|
			assert(item.class == list_to_sort[0].class, "all items must be of the same class.")
		end
	end

	def pre_parse_file(filename, extensions)
		assert(filename =~ /.+(#{extensions.keys.join("|")})/,
			"invalid specification of filename")
	end

	def post_parse_file
		# nothing to check
	end

	def pre_sort
		# nothing to check
	end

	def post_sort
		# nothing to check
		# Is there a property we could quickly run to help verify that the comparables are sorted?
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