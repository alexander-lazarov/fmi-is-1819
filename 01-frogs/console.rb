# frozen_string_literal: true

require './frogs'

num = gets.to_i

raise ArgumentError if num <= 0

Frogs.new(num).solve.each do |turn|
  puts turn
end
