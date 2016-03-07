require_relative 'parallel_sort.rb'

a = [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]

b = Sort.new(a)
# Or this:
#b = Sort.from_file("test.csv")

b.start(0.1)

b.puts_list

