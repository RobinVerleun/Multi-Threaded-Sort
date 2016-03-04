require_relative 'contract.rb'

class Sort
	include Contract
	

	@@allowed_extensions = {".csv"=>",", ".tsv"=>"\t", ".txt"=>" "}
	@duration
	@list_to_sort
	@result


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

		@result = Array.new(@list_to_sort.length)

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
		puts "starting with " + @list_to_sort.to_s
		
		start = Time.new
		parallel_merge_sort
		puts Time.new - start
		
		post_sort(@list_to_sort, @result)
		invariant(@list_to_sort)

		@result
	end

	def parallel_merge_sort(a=@list_to_sort, p=0, r=@list_to_sort.length-1)
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

			parallel_merge([a[p..q]], [a[q + 1..r]], p, r)
		end
	end

	def parallel_merge(left, right, result_low_index, result_high_index)
		# broken function that we want to make work

		left = left.flatten
		right = right.flatten
		
		if right.length > left.length # choose to have larger array come first
			t1 = Thread.new do
				parallel_merge(right, left, result_low_index, result_high_index)
			end
			t1.join
		elsif left.length + right.length == 1 # left has length 1, right is empty
			@result[result_low_index] = left[0]
		elsif left.length == 1 # => right.length == 1, also
			if left[0] <= right[0]
				@result[result_low_index] = left[0]
				@result[result_low_index + 1] = right[0]
			else
				@result[result_low_index] = right[0]
				@result[result_low_index + 1] = left[0]
			end
		else
			# find j s.t. right[j] <= left[length/2] <= right[j + 1] using binary search
			# right should be sorted at this point, but it is not - figure our why
			j = binary_search(right, left[left.length/2], 0, right.length - 1)
			t1 = Thread.new do
				parallel_merge(right[0..right.length/2], left[0..j], result_low_index, right.length/2 + j)
			end
			t2 = Thread.new do
				parallel_merge(right[right.length/2 + 1..-1], left[j + 1..-1], right.length/2 + j + 1, result_high_index)
			end
			t1.join
			t2.join
		end

		puts "merged " + left.to_s + " & " + right.to_s + " to get result " + @result.to_s
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
		# assert(high >= low, "value outside of list to sort", :RangeError)

		if val < array[low]
			puts "for array " + array.to_s + " and value " + val.to_s + ", returning " + low.to_s
			return low
		elsif val > array[high]
			puts "for array " + array.to_s + " and value " + val.to_s + ", returning " + high.to_s
			return high
		end

	    # return nil if high < low
	    
	    mid = (low + high) / 2

	    if val >= array[mid] and val <= array[mid + 1]
	    	puts "for array " + array.to_s + " and value " + val.to_s + ", returning " + mid.to_s
			return mid
		elsif val > array[mid]
			binary_search(array, val, mid + 1, high)
		elsif val < array[mid]
			binary_search(array, val, low, mid - 1)
  		end

  	end

 #  	def merge_sort(m=@list_to_sort)
	# 	return m if m.length <= 1
 
	# 	middle = m.length/2
	# 	t1 = Thread.new do
	# 		# sort the left
	# 		merge_sort(m[0...middle])
	# 	end
	# 	t2 = Thread.new do
	# 		# sort the right
	# 		merge_sort(m[middle..-1])
	# 	end
	# 	t1.join
	# 	t2.join

	# 	invariant(@list_to_sort)
	# 	merge(t1.value, t2.value)
	# end

	# def merge(left, right)
	# 	# function that works, but doesn't use threads
	# 	result = []
 #  		until left.empty? || right.empty?
 #    		result << (left.first<=right.first ? left.shift : right.shift)
 #  		end
 #  		invariant(@list_to_sort)
 #  		result + left + right
	# end
end