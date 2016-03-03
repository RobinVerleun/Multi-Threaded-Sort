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

		invariant(@list_to_sort)
	end

	def parse_file(filename)
		pre_parse_file(filename, @@allowed_extensions)
		@@allowed_extensions.each do |key, delimiter|
			if filename =~ /.+(#{key})/
				@delimiter = delimiter
				break
			end
		end

		invariant(@list_to_sort)
	end

	def sort
		
		start = Time.new
		result = merge_sort
		puts Time.new - start
		
		post_sort(@list_to_sort, result)
		invariant(@list_to_sort)

		result
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

		invariant(@list_to_sort)
		merge(t1.value, t2.value)
	end

	def merge(left, right)
		# function that works, but doesn't use threads
		result = []
  		until left.empty? || right.empty?
    		result << (left.first<=right.first ? left.shift : right.shift)
  		end
  		invariant(@list_to_sort)
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

			parallel_merge(t1.value, t2.value) # join and get results in one go
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
				parallel_merge(right, left)
			end
		elsif left.length + right.length == 1
			# left has length 1, right is empty
			result[0] = left[0]
		elsif right.length == 1 # => left.length == 1 also
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
				parallel_merge(right[0..right.length/2], left[0..j], result[0..right.length/2 + j])
			end
			t2 = Thread.new do
				parallel_merge(right[right.length/2 + 1..-1], left[j + 1..-1], result[right.length/2 + j + 1..-1])
			end
			t1.join
			t2.join
		end
	end

	# def find_split_index(array, val)
	# 	# TODO: parallelize this (& make it recursive)

	# 	low = 0
	# 	high = array.length-1

	# 	if val <= array[low]
	# 		return low
	# 	elsif val >= array[high]
	# 		return high
	# 	end

	# 	while high > low

	# 		mid = (low + high)/2
	# 		puts mid

	# 		if val >= array[mid] and val <= array[mid + 1]
	# 			return mid
	# 		elsif val > array[mid]
	# 			low = mid + 1
	# 		elsif val < array[mid]
	# 			high = mid - 1
	# 		end
	# 	end
	# end

	# returns index j such that array[j] <= val <= array[j + 1]
	def binary_search(array, val, low, high)
		assert(high >= low, "value outside of list to sort", :RangeError)
	    return nil if high < low
	    
	    mid = (low + high) / 2

	    if val >= array[mid] and val <= array[mid + 1]
			return mid
		elsif val > array[mid]
			binary_search(array, val, mid + 1, high)
		elsif val < array[mid]
			binary_search(array, val, low, mid - 1)
		end
	end
end