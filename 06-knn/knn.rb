# frozen_string_literal: true

require 'CSV'

filename = 'iris.data'

class DataPoint
  attr_reader :attr1, :attr2, :attr3, :attr4, :klass, :guess

  attr_reader :calculated_distance

  def initialize(attr1, attr2, attr3, attr4, klass)
    @attr1 = attr1.to_f
    @attr2 = attr2.to_f
    @attr3 = attr3.to_f
    @attr4 = attr4.to_f

    @klass = klass
  end

  def distance(other_data)
    @calculated_distance = Math.sqrt(
      (attr1 - other_data.attr1) * (attr1 - other_data.attr1) +
        (attr2 - other_data.attr2) * (attr2 - other_data.attr2) +
        (attr3 - other_data.attr3) * (attr3 - other_data.attr3) +
        (attr4 - other_data.attr4) * (attr4 - other_data.attr4)
    )
  end

  def guess(k, match_data)
    nearest_k = match_data.sort_by { |d| d.distance(self) }[0..k]

    grouped = nearest_k.group_by(&:klass).map do |klass, v|
      {
        klass: klass,
        count: v.count,
        min_distance: v.map(&:calculated_distance).min
      }
    end

    guess = grouped.min do |a, b|
      a[:count] <=> b[:count]
    end[:klass]

    @guess = guess
  end

  def guessed?
    @guess == klass
  end
end

data = []

CSV.foreach(filename) do |row|
  next unless row[0]

  data << DataPoint.new(
    row[0], row[1], row[2], row[3], row[4]
  )
end

data.shuffle!

test_size = 10

test_data = data[0..(test_size-1)]
match_data = data[test_size..(data.count-1)]

k = gets.to_i

guessed_count = 0

test_data.each do |data_point|
  if data_point.guess(k, match_data) == data_point.klass
    puts "Correctly guessed #{data_point.klass}"
    guessed_count += 1
  else
    puts "Error, guessed: #{data_point.guess(k, match_data)}, actually: #{data_point.klass}"
  end
end

puts "Accuracy #{guessed_count}/#{test_size} (#{(guessed_count.to_f/test_size)*100}%)"
