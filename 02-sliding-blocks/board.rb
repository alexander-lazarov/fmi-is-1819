# frozen_string_literal: true

require_relative './game'

class Board < SimpleDelegator
  attr_accessor :parent, :path_length, :parent_dir

  def initialize(board)
    super(board)
    @path_length = 0
  end

  def solvable?
    without_zeroes = reject(&:zero?)

    inversions = 0

    without_zeroes.each_with_index do |el, i|
      next if i.zero?

      inversions += without_zeroes[0..(i - 1)].count { |c| c > el }
    end

    (inversions % 2).zero?
  end

  def manhattan_distance
    total = 0

    each_with_index do |el, i|
      next if el.zero?

      total += Board.distance_matrix[i][el - 1]
    end

    total
  end

  def turns
    result = []

    zero_position = find_index(0)

    Board.neighbours_matrix[zero_position].each do |dir, target|
      new_board = dup

      new_board[zero_position], new_board[target] =
        new_board[target], new_board[zero_position]

      new_board.parent = self
      new_board.path_length = path_length + 1
      new_board.parent_dir = dir

      result << new_board
    end

    result
  end

  class << self
    def target_board
      @target_board ||= new(target_board_array)
    end

    def target_board_array
      result = (1..(Game.size - 1)).to_a

      result.push(0)

      result
    end

    def distance_matrix
      @distance_matrix ||= build_distance_matrix
    end

    def neighbours_matrix
      @neighbours_matrix ||= build_neighbours_matrix
    end

    private

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # Distance matrix used by Manhattan Distance heuristics
    def build_distance_matrix
      result = []

      Game.size.times do |i|
        result << []

        Game.size.times do |j|
          xi = i % Game.width
          yi = i / Game.width
          xj = j % Game.width
          yj = j / Game.width

          result[i][j] = (xi - xj).abs + (yi - yj).abs
        end
      end

      result
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def build_neighbours_matrix
      result = []

      Game.size.times do |i|
        row = {}

        xi = i % Game.width
        xj = i / Game.width

        row[:left] = (i + 1) if (xi + 1) < Game.width
        row[:right] = (i - 1) unless xi.zero?
        row[:up] = i + Game.width if (xj + 1) < Game.height
        row[:down] = i - Game.width unless xj.zero?

        result << row
      end

      result
    end
  end
end
