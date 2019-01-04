# frozen_string_literal: true

require 'CSV'

FILENAME = 'house-votes-84.data'
CROSS_TRAINING_SETS = 10

ATTR_COUNT = 16

KLASSES = %w[republican democrat].freeze

class DataRow
  attr_reader :klass

  def initialize(row)
    @klass = row[0]
    @attrs = row[1..-1]
  end

  def attr(n)
    @attrs[n]
  end
end

class DataModel
  attr_reader :klass_counts, :freq_tables

  def initialize(data_set)
    @data_set = data_set

    @total_num = @data_set.size
    @freq_tables = (0...ATTR_COUNT).map { |i| attr_freq_table(i) }
    @klass_counts = {}

    build_klass_counts
  end

  def classify(data_row)
    rep_prob = prob_klass('republican')
    dem_prob = prob_klass('democrat')

    ATTR_COUNT.times do |i|
      attr_val = data_row.attr(i)

      next if attr_val == '?'

      rep_prob *= prob_attr_klass(i, attr_val, 'republican')
      dem_prob *= prob_attr_klass(i, attr_val, 'democrat')
    end

    rep_prob > dem_prob ? 'republican' : 'democrat'
  end

  private

  def build_klass_counts
    KLASSES.each do |klass|
      @klass_counts[klass] = 0
    end

    @data_set.each do |data_row|
      @klass_counts[data_row.klass] += 1
    end
  end

  def attr_freq_table(i)
    table = {
      'republican' => {
        'y' => 0,
        'n' => 0,
        'total' => 0
      },
      'democrat' => {
        'y' => 0,
        'n' => 0,
        'total' => 0
      }
    }

    @data_set.each do |data_row|
      val = data_row.attr(i)

      next if val == '?'

      table[data_row.klass]['total'] += 1
      table[data_row.klass][val] += 1
    end

    table
  end

  def prob_klass(klass)
    @klass_counts[klass].to_f / @total_num.to_f
  end

  def prob_attr_klass(i, attr_val, klass)
    table = @freq_tables[i]

    p = table[klass][attr_val]
    q = table[klass]['total']

    if p.zero?
      1.to_f / (1 + q).to_f
    else
      p.to_f / q.to_f
    end
  end
end

data = []

CSV.foreach(FILENAME) do |row|
  data << DataRow.new(row)
end

data.shuffle!

def split_to_groups(arr, num)
  result = []
  size = (arr.size.to_f / num).ceil

  num.times do |i|
    l = i * size
    r = (i + 1) * size
    result << arr[l...r]
  end

  result
end

sets = split_to_groups(data, CROSS_TRAINING_SETS)

models = sets.map { |set| DataModel.new(set) }

total_guesses = 0
total_total = 0

CROSS_TRAINING_SETS.times do |i|
  guesses = 0
  total = 0

  current_model = models[i]

  CROSS_TRAINING_SETS.times do |j|
    next if i == j

    current_set = sets[j]

    current_set.each do |data_row|
      total += 1

      guessed = current_model.classify(data_row)

      guesses += 1 if guessed == data_row.klass
    end
  end

  eff = guesses.to_f / total.to_f

  total_guesses += guesses
  total_total += total

  puts "Training set #{i + 1}, eff #{guesses}/#{total} (#{eff * 100}%)"
end

total_eff = total_guesses.to_f / total_total

puts "Overall: #{total_guesses}/#{total_total} (#{total_eff * 100}%)"
