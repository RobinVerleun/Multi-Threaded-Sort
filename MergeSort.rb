
class MergeSort

	def Sort(ListToSort, left, right)

		if left < right
			middle = ( ( left + right ) / 2 ).round
			t1 = Thread.new{Sort(ListToSort, left, middle)}
			t2 = Thread.new{Sort(ListToSort, middle+1, right)}
		end
		

	end