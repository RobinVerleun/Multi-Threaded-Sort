require_relative 'parallel_sort.rb'

a = [ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
stringlist = [
	"T - Starts with T",
	"A - Starts with A",
	"C - Starts with C",
	"Z - Starts with Z",
	"K - Starts with K",
	"T - Starts with T",
	"H - Starts with H",
	"I - Starts with I",
	"R - Starts with R",
	"L - Starts with L",
	"O - Starts with O"
]

b = Sort.new(a)
# Or this:
#b = Sort.from_file("test.csv")

b.start(10)

b.puts_list


b.new_list(stringlist)

b.start(10)

b.puts_list

