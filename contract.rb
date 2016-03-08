require_relative 'assertions.rb'

module Contract
	include Assertions

	def pre_sort(duration_, self_)
		assert(duration_.is_a?(Numeric), "Invalid duration - should be a number.", :ArgumentError)
		assert(duration_ > 0, "Must have positive duration.", :ArgumentError)
		assert(self.is_a?(Array), "Can only be called on Array type object.", :TypeError)
		assert(self.length > 0, "Cannot be called on zero elements.", :ArgumentError)
		assert(self_.all? {|obj| obj.is_a?(self_[0].class) }, "All elements must be of the same type.", :ArgumentError)
	end

	def post_sort(sorted_list, original_list, comparator)
		(0..sorted_list.length - 2).step(1) { |i|
			assert(comparator.call(sorted_list[i], sorted_list[i+1]) < 1, "List is not sorted.", :RuntimeError)
		}
		assert(sorted_list.length == original_list.length, 
			"sorting a list should not change its length", :RangeError)
		assert(
			original_list.each_with_object(Hash.new(0)) { |obj,counts| counts[obj] += 1 } == 
			sorted_list.each_with_object(Hash.new(0)) { |obj,counts| counts[obj] += 1 },
			"Should be the same amount of each object after sorting as before sorting",
			:RuntimeError)
	end

end

	