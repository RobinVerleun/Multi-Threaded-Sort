require_relative 'assertions'

class Sort
	include Assertions
	
	@@allowed_extensions = {".csv"=>",", ".tsv"=>"\t", ".txt"=>" "}

	@duration
	@list_to_sort

	def initialize(*args)
		assert(args.length >= 2, "must provide duration and objects", :ArgumentError)
		assert(is_number?(args[0]), "must provide numeric duration", :ArgumentError)

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

		assert(@duration.is_a?(Numeric), "duration should be a number", :TypeError)
		assert(@list_to_sort.kind_of?(Array), 
			"objects to sort must be stored in Array", :TypeError)
		assert(@list_to_sort.length > 0, 
			"no valid objects to sort", :RangeError)
		assert(@list_to_sort.all? {|i| i.is_a?(@list_to_sort[0].class) }, 
			"all elements must be of same type", :TypeError)
		# ^^ http://stackoverflow.com/questions/12158954/can-i-check-if-an-array-e-g-just-holds-integers-in-ruby
		# answered by Sergio Tulentsev on Aug 28 '12 at 12:14
		assert(@list_to_sort.all? {|i| i.respond_to?("<=>") }, 
			"all elements must be comparable", :NoMethodError)
	end

	def parse_file(filename)
		assert(filename =~ /.+(#{@@allowed_extensions.keys.join("|")})/,
			"invalid specification of filename", :ArgumentError)

		@@allowed_extensions.each do |key, delimiter|
			if filename =~ /.+(#{key})/
				@delimiter = delimiter
				break
			end
		end

		# add each element to the array

	end

	def sort
		# no preconditions, since the constructor worked fine?
		
		start = Time.new
		result = merge_sort.to_s
		puts result
		# puts parallel_merge_sort.to_s
		puts Time.new - start

		# check the post-conditions:
		assert(result.length = @list_to_sort.length, 
			"sorting a list should not change its length", :RangeError)
		assert(
			@list_to_sort.each_with_object(Hash.new(0)) { |obj,counts| counts[obj] += 1 } == 
			result.each_with_object(Hash.new(0)) { |obj,counts| counts[obj] += 1 },
			"sorting a list should only move elements - not change them",
			:TypeError)
		assert(result.each_cons(2).all? { |a, b| (a <=> b) != 1 }, 
			"elements must be in sorted order", :RangeError)
		# ^^ http://stackoverflow.com/questions/8015775/check-to-see-if-an-array-is-already-sorted
		# answered by Marc-André Lafortune on Nov 4 '11 at 21:34

		# check the invariant:
		assert(@duration.is_a?(Numeric), "duration should be a number", :TypeError)
		assert(@list_to_sort.kind_of?(Array), 
			"objects to sort must be stored in Array", :TypeError)
		assert(@list_to_sort.length > 0, 
			"no valid objects to sort", :RangeError)
		assert(@list_to_sort.all? {|i| i.is_a?(@list_to_sort[0].class) }, 
			"all elements must be of same type", :TypeError)
		# ^^ http://stackoverflow.com/questions/12158954/can-i-check-if-an-array-e-g-just-holds-integers-in-ruby
		# answered by Sergio Tulentsev on Aug 28 '12 at 12:14
		assert(@list_to_sort.all? {|i| i.respond_to?("<=>") }, 
			"all elements must be comparable", :NoMethodError)
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
			parallel_merge(a[p..q], a[q + 1..r], Array.new(@list_to_sort.length))
		end
	end

	def parallel_merge(left, right, result)
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