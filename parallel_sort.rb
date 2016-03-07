require 'timeout'
require_relative 'contract.rb'

class Sort	
	include Contract

	@list_to_sort
	@duration
	@comparator

	def initialize(args)
		pre_initialize(args)

		@list_to_sort = args
		@comparator = Proc.new { |v1, v2| v1 <=> v2 }

		invariant(@list_to_sort, @comparator)
	end

	def self.from_file(filename)
		#pre_parse_file(filename, @@allowed_extensions)
		extensions = {".csv"=>",", ".tsv"=>"\t", ".txt"=>" "}

		delimiter = extensions[filename[-4..-1]]
		the_list = []
		File.open(filename, "r") do |infile|
			the_list = infile.gets.split(delimiter)
		end

		Sort.new(the_list)
	end

	def start(duration_)
		pre_start(duration_)

		@duration = duration_
		begin
			Timeout::timeout(@duration) do
				parallel_merge_sort(@list_to_sort, 0, @list_to_sort.size)
			end
			rescue Timeout::Error
				puts "Sort timed out."
				return
			end

		invariant(@list_to_sort, @comparator)

		return @list_to_sort
	end

	def parallel_merge_sort(a=@list_to_sort, p=0, r=@list_to_sort.length)

		pre_parallel_merge_sort(a,p,r)

		if p < r
			q = ((p + r)/2).floor

			t1 = Thread.new{ parallel_merge_sort(a, p, q) }
			t2 = Thread.new{ parallel_merge_sort(a, q + 1, r) }

			#Notes show a way to have a thread-hash like object - we want to call join on all of them at once?
			t1.join
			t2.join

			parallel_merge(a[p..q], a[q + 1..r], a, p)

		end

		#post_parallel_merge_sort(@list_to_sort)
		invariant(@list_to_sort, @comparator)

	end

	def parallel_merge(left_chunk, right_chunk, list_to_sort, start_index)
		
		pre_parallel_merge(left_chunk, right_chunk, list_to_sort, start_index)

		threads = []

		if right_chunk.length > left_chunk.length # choose to have larger array come first
			parallel_merge(right_chunk, left_chunk, list_to_sort, start_index)
			return
		end

		#List of length one
		if left_chunk.length + right_chunk.length == 1
			list_to_sort[start_index] = left_chunk[0]

		#List of length 2
		elsif left_chunk.length == 1
			if left_chunk[0] <= right_chunk[0]
				list_to_sort[start_index] = left_chunk[0]
				list_to_sort[start_index + 1] = right_chunk[0]
			else
				list_to_sort[start_index] = right_chunk[0]
				list_to_sort[start_index + 1] = left_chunk[0]
			end

		#Array of substance - find middle points, and split the array	
		else
			lm = (left_chunk.size - 1) / 2
			rm = (right_chunk.find_index{|item| @comparator.call(item, left_chunk[lm]) > -1} || right_chunk.size) - 1
			if rm >= 0
				#Right chunk has enough size to have a middle value - thread left and right chunkcs independently
				threads << Thread.new{
					parallel_merge(
						left_chunk[0..lm], 
						right_chunk[0..rm], 
						list_to_sort, 
						start_index)
				}
				threads << Thread.new{
					parallel_merge(
						left_chunk[lm+1..-1],
						right_chunk[rm+1..-1],
						list_to_sort,
				 		start_index + lm + rm + 2)
				}
			else
				#Right has next to no elements in it - thread half of the left chunk to one side, half to the other side.
				#Incorporate the right array into one thread in case of 0-2 element arrays
				threads << Thread.new{
					parallel_merge(
						left_chunk[0..lm],
						[],
						list_to_sort,
						start_index)
				}
				threads << Thread.new{
					parallel_merge(
						left_chunk[lm+1..-1],
						right_chunk[0..-1],
						list_to_sort,
						start_index + lm + 1)
				}
			end

		end
		threads.each { |t| t.join }

		post_parallel_merge
		invariant(@list_to_sort, @comparator)

	end

	def new_list(objects)
		pre_new_list(objects)

		@list_to_sort = objects

		post_new_list(@list_to_sort, @comparator)
		invariant(@list_to_sort, @comparator)
	end

	def puts_list
		puts
		@list_to_sort.each { |x| puts x }
	end

end
 	