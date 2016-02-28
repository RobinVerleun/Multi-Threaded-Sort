module Assertions
	extend self
	def assert(condition, message="", exception=:RuntimeError)
  		raise Object.const_get(exception).new(message) unless condition
  	end

  	def is_number? string
  		true if Float(string) rescue false
	end
	# http://stackoverflow.com/questions/5661466/test-if-string-is-a-number-in-ruby-on-rails
	# Jakob S's answer on Apr 14 '11
end