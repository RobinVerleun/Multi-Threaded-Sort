require_relative 'parallel_sort.rb'

# a = [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
a = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

b = Sort.new(a)
# Or this:
#b = Sort.from_file("test.csv")

b.define_comparator(Proc.new { |v1, v2| v2 <=> v1 }) # sort descending

b.start(0.1)

b.puts_list

