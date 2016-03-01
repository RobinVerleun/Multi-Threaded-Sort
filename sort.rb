require_relative 'contract.rb'

class Sort
	include Contract
	

	@@allowed_extensions = {".csv"=>",", ".tsv"=>"\t", ".txt"=>" "}
	@duration
	@list_to_sort


	def initialize(*args)

		pre_initialize(*args)

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

		post_initialize(@list_to_sort)
	end

	def parse_file(filename)
		pre_parse_file(filename, @@allowed_extensions)

		@@allowed_extensions.each do |key, delimiter|
			if filename =~ /.+(#{key})/
				@delimiter = delimiter
				break
			end
		end
	end

	def sort
		start = Time.new
		puts merge_sort.to_s
		puts Time.new - start
	end

	def merge_sort(m=@list_to_sort)
		return m if m.length <= 1
 
		middle = m.length / 2
		t1 = Thread.new do
			# sort the left
			merge_sort(m[0...middle])
		end
		t2 = Thread.new do
			# sort the right
			merge_sort(m[middle..-1])
		end

		# merge left and right
		merge(t1.value, t2.value)
	end

	def merge(left, right)
		result = []
  		until left.empty? || right.empty?
    		result << (left.first<=right.first ? left.shift : right.shift)
  		end
  		result + left + right
	end

end