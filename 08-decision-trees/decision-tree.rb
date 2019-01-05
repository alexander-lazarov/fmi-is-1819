# frozen_string_literal: true

require 'CSV'

FILENAME = 'breast-cancer.data'
CROSS_TRAINING_SETS = 3
MISSING_DATA_SYMBOL = '?'
K = 7
ATTR_NUM = 9

class Hash
  def largest_hash_key
    max_by { |_k, v| v }.first
  end
end

def load_data
  data = []

  CSV.foreach(FILENAME) do |row|
    data << DataRow.new(row)
  end

  data.shuffle
end

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

def entropy(counts)
  total = counts.sum.to_f
  p = counts.map { |v| v.to_f / total }

  p.map { |v|  - (v * Math.log(v, 2)) }.sum
end

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

class DataSet
  def initialize(data_rows)
    @data_rows = data_rows
  end

  def attr_values(attr_num)
    @data_rows.map { |d| d.attr(attr_num) }.uniq - [MISSING_DATA_SYMBOL]
  end

  def gain(attr_num)
    entropy_klass - entropy_klass_attribute(attr_num)
  end

  def count
    @data_rows.count
  end

  def klasses
    @data_rows.map(&:klass).uniq
  end

  def split_by(attr_num)
    result = @data_rows.group_by { |data_row| data_row.attr(attr_num) }

    result.each do |attr_val, data_rows|
      result[attr_val] = DataSet.new(data_rows)
    end

    result
  end

  def most_probable_klass
    g = @data_rows.group_by(&:klass)

    g.each do |k, v|
      g[k] = v.size
    end

    g.largest_hash_key
  end

  def most_probable_attr(attr_num)
    g = @data_rows.reject { |data_row| data_row.attr(attr_num) == MISSING_DATA_SYMBOL }.group_by { |data_row| data_row.attr(attr_num) }

    g.each do |k, v|
      g[k] = v.size
    end

    g.largest_hash_key
  end

  private

  def entropy_klass
    total = 0
    counts = Hash.new(0)

    @data_rows.each do |data_row|
      total += 1
      counts[data_row.klass] += 1
    end

    entropy(counts.values)
  end

  def entropy_klass_attribute(attr_num)
    counts = {}
    totals = Hash.new(0)
    total = 0

    @data_rows.each do |data_row|
      klass = data_row.klass
      attr_val = data_row.attr(attr_num)

      unless counts.key?(attr_val)
        counts[attr_val] = Hash.new(0)
      end

      counts[attr_val][klass] += 1
      totals[attr_val] += 1
      total += 1
    end

    total = total.to_f
    totals.each { |k, v| totals[k] = v.to_f / total }

    counts.map do |attr_val, attr_counts|
      totals[attr_val] * entropy(attr_counts.values) 
    end.sum
  end
end

class DecisionTree
  def initialize(data_set, attributes)
    @data_set = data_set
    @attributes = attributes
    @children = {}
    @attribute = nil

    build_child_trees
  end

  def classify(data_row)
    return most_probable_klass if @attribute.nil?
    attr_val = data_row.attr(@attribute)

    attr_val = most_probable_attr if attr_val == MISSING_DATA_SYMBOL || !@children.key?(attr_val)

    @children[attr_val].classify(data_row)
  end

  private

  def most_probable_klass
    @most_probable_klass ||= @data_set.most_probable_klass
  end

  def most_probable_attr
    @most_probable_attr ||= @data_set.most_probable_attr(@attribute)
  end
  
  def leaf?
    @children.count.zero?
  end

  def build_child_trees
    return if @attributes.empty?
    return if @data_set.count <= K
    return if @data_set.klasses.count <= 1

    @attribute = gains.largest_hash_key

    @data_set.split_by(@attribute).each do |attr_val, data_set|
      @children[attr_val] = DecisionTree.new(data_set, @attributes - [@attribute]) 
    end
  end

  def gains
    result = {}

    @attributes.each do |attr_num|
      result[attr_num] = @data_set.gain(attr_num)
    end

    result
  end
end

sets = split_to_groups(load_data, CROSS_TRAINING_SETS)
trees = sets.map { |set| DecisionTree.new(DataSet.new(set), (0...ATTR_NUM).to_a) }

total_guesses = 0
total_total = 0

CROSS_TRAINING_SETS.times do |i|
  guesses = 0
  total = 0

  current_tree = trees[i]

  CROSS_TRAINING_SETS.times do |j|
    next if i == j

    current_set = sets[j]

    current_set.each do |data_row|
      total += 1

      guessed = current_tree.classify(data_row)

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
