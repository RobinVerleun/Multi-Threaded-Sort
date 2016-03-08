require_relative 'parallel_sort.rb'

a = [ 10, 3, 4, -2, -5, 1, 0, 14, 15, 6, 0 ]

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

puts "Sorting stringlist in ascending order with 0.01s time limit."

puts stringlist.sort(0.01)
puts "-----------"

puts "Sorting stringlist in descending order using a code block."

puts stringlist.sort(0.01){ |v1, v2| v2 <=> v1 }
puts "-----------"

puts "Sorting stringlist with 0.0001s timelimit."

puts stringlist.sort(0.0001)


puts "Finished."






def from_file(filename)
	#pre_parse_file(filename, @@allowed_extensions)
	extensions = {".csv"=>",", ".tsv"=>"\t", ".txt"=>" "}
	delimiter = extensions[filename[-4..-1]]
	the_list = []
	File.open(filename, "r") do |infile|
		the_list = infile.gets.split(delimiter)
	end

	the_list
end

