require_relative 'assertions'

class Sort
	include Assertions
	
	@@allowed_extensions = {".csv"=>",", ".tsv"=>"\t", ".txt"=>" "}

	@duration
	@list_to_sort

	def initialize(*args)
		puts args.length.to_s
		assert(args.length >= 2, "must provide duration and objects")
		assert(is_number?(args[0]), "must provide numeric duration")

		@duration = args[0].to_f

		# filename given where extension tells what delimiter is
		if args.length == 2
			puts "got a file"

			# read from the file, separating items by delimiter
			@list_to_sort = parse_file(args[1])

		# proc followed by objects given
		elsif args[1].is_a?(Proc)
			puts "got a proc"
			# assign the proc to <=> somehow

			@list_to_sort = args.drop(2)

		# list of objects that already are comparable given
		else
			puts "got some args"

			@list_to_sort = args.drop(1)
		end

		assert(@list_to_sort.kind_of?(Array), "array of objects to sort not present")
		assert(@list_to_sort.length > 0, "no valid objects to sort")
		# TODO: assert that all of the elements in the list have the same class
	end

	def parse_file(filename)
		assert(filename =~ /.+(#{@@allowed_extensions.keys.join("|")})/,
			"invalid specification of filename")

		@@allowed_extensions.each do |key, delimiter|
			if filename =~ /.+(#{key})/
				@delimiter = delimiter
				break
			end
		end

		# add each element to the array

	end

end