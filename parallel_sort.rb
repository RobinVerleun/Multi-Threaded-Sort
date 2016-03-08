require 'timeout'
require_relative 'contract.rb'

class Array	
	include Contract

	@list_to_sort
	@duration
	@comparator

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

	def sort(duration_, &block)
		pre_sort(duration_)

		@duration = duration_
		@list_to_sort = self
		
		if block_given? 
			@comparator = block
		else
			@comparator = Proc.new { |v1, v2| v1 <=> v2 }
		end
		
		begin
			Timeout::timeout(@duration) do
				parallel_merge_sort(@list_to_sort, 0, @list_to_sort.size)
			end
			rescue Timeout::Error
				print "Sort timed out."
				return
			end

		post_sort(@list_to_sort, self, @comparator)
		return @list_to_sort
	end

	def parallel_merge_sort(a=@list_to_sort, p=0, r=@list_to_sort.length)

		pre_parallel_merge_sort(a,p,r)

		if p < r
			q = ((p + r)/2).floor

			t1 = Thread.new{ parallel_merge_sort(a, p, q) }
			t2 = Thread.new{ parallel_merge_sort(a, q + 1, r) }

			t1.join
			t2.join

			parallel_merge(a[p..q], a[q + 1..r], a, p)

		end
	end

	def parallel_merge(left_chunk, right_chunk, list_to_sort, start_index)

		pre_parallel_merge(left_chunk, right_chunk, list_to_sort, start_index)

		threads = []

		if right_chunk.length > left_chunk.length 
			parallel_merge(right_chunk, left_chunk, list_to_sort, start_index)
			return
		end

		if left_chunk.length + right_chunk.length == 1
			list_to_sort[start_index] = left_chunk[0]

		elsif left_chunk.length == 1
			if @comparator.call(left_chunk[0], right_chunk[0]) < 1
				list_to_sort[start_index] = left_chunk[0]
				list_to_sort[start_index + 1] = right_chunk[0]
			else
				list_to_sort[start_index] = right_chunk[0]
				list_to_sort[start_index + 1] = left_chunk[0]
			end
	
		else
			lm = (left_chunk.size - 1) / 2
			rm = (right_chunk.find_index{|item| @comparator.call(item, 
				left_chunk[lm]) > -1} || right_chunk.size) - 1
			
			if rm >= 0
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
	end
end
 	