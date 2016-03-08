require 'timeout'
require_relative 'contract.rb'

class Array	
	include Contract

	def sort(duration_, &block)
		pre_sort(duration_, self)

		duration = duration_
		list_to_sort = self.dup
		comparator = nil

		if block_given? 
			comparator = block
		else
			comparator = Proc.new { |v1, v2| v1 <=> v2 }
		end
		
		Timeout::timeout(duration) do
			parallel_merge_sort(list_to_sort, 0, list_to_sort.size, comparator)
		end

		post_sort(list_to_sort, self, comparator)
		return list_to_sort
	end

	def parallel_merge_sort(a, p, r, comparator)

		if p < r
			q = ((p + r)/2).floor

			t1 = Thread.new{ parallel_merge_sort(a, p, q, comparator) }
			t2 = Thread.new{ parallel_merge_sort(a, q + 1, r, comparator) }

			t1.join
			t2.join

			parallel_merge(a[p..q], a[q + 1..r], a, p, comparator)

		end
	end

	def parallel_merge(left_chunk, right_chunk, list_to_sort, start_index, comparator)

		threads = []

		if right_chunk.length > left_chunk.length 
			parallel_merge(right_chunk, left_chunk, list_to_sort, start_index, comparator)
			return
		end

		if left_chunk.length + right_chunk.length == 1
			list_to_sort[start_index] = left_chunk[0]

		elsif left_chunk.length == 1
			if comparator.call(left_chunk[0], right_chunk[0]) < 1
				list_to_sort[start_index] = left_chunk[0]
				list_to_sort[start_index + 1] = right_chunk[0]
			else
				list_to_sort[start_index] = right_chunk[0]
				list_to_sort[start_index + 1] = left_chunk[0]
			end
	
		else
			lm = (left_chunk.size - 1) / 2
			rm = (right_chunk.find_index{|item| comparator.call(item, 
				left_chunk[lm]) > -1} || right_chunk.size) - 1
			
			if rm >= 0
				threads << Thread.new{
					parallel_merge(
						left_chunk[0..lm], 
						right_chunk[0..rm], 
						list_to_sort, 
						start_index,
						comparator)
				}
				threads << Thread.new{
					parallel_merge(
						left_chunk[lm+1..-1],
						right_chunk[rm+1..-1],
						list_to_sort,
				 		start_index + lm + rm + 2,
				 		comparator)
				}

			else
				threads << Thread.new{
					parallel_merge(
						left_chunk[0..lm],
						[],
						list_to_sort,
						start_index,
						comparator)
				}
				threads << Thread.new{
					parallel_merge(
						left_chunk[lm+1..-1],
						right_chunk[0..-1],
						list_to_sort,
						start_index + lm + 1,
						comparator)
				}
			end
		end

		threads.each { |t| t.join }
	end
	

	private :parallel_merge, :parallel_merge_sort
end
 	