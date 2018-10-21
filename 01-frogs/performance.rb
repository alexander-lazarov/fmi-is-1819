# frozen_string_literal: true

require './frogs'
require 'benchmark'

TIME_LIMIT = 0.5

n = 1
result = nil

while n == 1 || result.real < TIME_LIMIT
  result = Benchmark.measure { Frogs.new(n).solve }

  puts "#{n} #{result.real}"

  n += 1
end
