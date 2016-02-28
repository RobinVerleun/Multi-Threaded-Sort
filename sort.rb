require_relative 'assertions'

class Sort
	include Assertions
	
	@@allowed_extensions = {".csv"=>",", ".tsv"=>"\t", ".txt"=>" "}

	@duration
	@list_to_sort
	@result

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

		@result = Array.new(@list_to_sort.length)

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

	def sort
		start = Time.new
		puts merge_sort.to_s
		# puts parallel_merge_sort.to_s
		puts Time.new - start
	end

	def merge_sort(m=@list_to_sort)
		return m if m.length <= 1
 
		middle = m.length/2
		t1 = Thread.new do
			# sort the left
			merge_sort(m[0...middle])
		end
		t2 = Thread.new do
			# sort the right
			merge_sort(m[middle..-1])
		end
		t1.join
		t2.join
		merge(t1.value, t2.value)
	end

	def merge(left, right)
		# function that works, but doesn't use threads
		result = []
  		until left.empty? || right.empty?
    		result << (left.first<=right.first ? left.shift : right.shift)
  		end
  		result + left + right
	end

	def parallel_merge_sort(a=@list_to_sort, p=0, r=@list_to_sort.length-1)
		puts "sorting: " + a.to_s
		if p < r
			q = (p + r)/2
			t1 = Thread.new do
				# sort the left
				parallel_merge_sort(a, p, q)
			end
			t2 = Thread.new do
				# sort the right
				parallel_merge_sort(a, q + 1, r)
			end

			t1.join
			t2.join
			parallel_merge(a[p..q], a[q + 1..r])
		end
	end

	def parallel_merge(left, right, result=@result)
		# broken function that we want to make work

		left = left.flatten
		right = right.flatten
		# puts left.to_s
		# puts right.to_s
		puts result.to_s
		if right.length > left.length
			t1 = Thread.new do
				parallel_merge(right, left, result)
			end
			t1.value
			# return t1.value # implicit join
		elsif left.length + right.length == 1
			result[0] = left[0]
			result
			# return left
		elsif right.length == 1 # and left.length == 1
			if left[0] <= right[0]
				result[0] = left[0]
				result[1] = right[0]
				result
			else
				result[0] = right[0]
				result[1] = left [0]
				result
			end
		else
			# find j st right[j] <= left[length/2] <= right[j + 1] using binary search
			j = find_split_index(right, left[left.length/2])
			t1 = Thread.new do
				puts "shorter result: " + result[0..right.length/2 + j]
				parallel_merge(right[0..right.length/2], left[0..j], result[0..right.length/2 + j])
			end
			t2 = Thread.new do
				puts "shorter result: " + result[right.length/2 + j + 1..-1].to_s
				parallel_merge(right[right.length/2 + 1..-1], left[j + 1..-1], result[right.length/2 + j + 1..-1])
			end
			# t1.join
			# t2.join

			t1.value + t2.value
			# return t1.value + t2.value # implicit join
		end
	end

	def find_split_index(array, val)
		low = 0
		high = array.length-1

		if val <= array[low]
			return low
		elsif val >= array[high]
			return high
		end

		while high > low

			mid = (low + high)/2

			if val > array[mid] and val < array[mid + 1]
				return mid
			elsif val > array[mid]
				low = mid + 1
			elsif val < array[mid]
				high = mid - 1
			end
		end
	end
end