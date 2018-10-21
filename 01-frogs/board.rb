# frozen_string_literal: true

class Board < SimpleDelegator
  attr_accessor :parent

  NON_BLOCKNG = /^((L*(LR)*L?\ L?(RL)*R*)|(R*(RL)*R?\ R?(LR)*L*))$/

  def initialize(board_str)
    super(board_str)
  end

  def self.initial_board(size)
    new('L' * size + ' ' + 'R' * size)
  end

  def self.target_board(size)
    initial_board(size).reverse
  end

  def turns
    current_i = index(' ')

    result = []
    prev_i = current_i - 1
    prev_prev_i = current_i - 2

    next_i = current_i + 1
    next_next_i = current_i + 2

    if prev_i >= 0 && self[prev_i] == 'L'
      new_board = dup
      new_board.parent = self
      new_board[current_i], new_board[prev_i] =
        new_board[prev_i], new_board[current_i]

      result << new_board
    end

    if prev_prev_i >= 0 && self[prev_prev_i] == 'L'
      new_board = dup
      new_board.parent = self
      new_board[current_i], new_board[prev_prev_i] =
        new_board[prev_prev_i], new_board[current_i]

      result << new_board
    end

    if next_i < length && self[next_i] == 'R'
      new_board = dup
      new_board.parent = self
      new_board[current_i], new_board[next_i] =
        new_board[next_i], new_board[current_i]

      result << new_board
    end

    if next_next_i < length && self[next_next_i] == 'R'
      new_board = dup
      new_board.parent = self
      new_board[current_i], new_board[next_next_i] =
        new_board[next_next_i], new_board[current_i]

      result << new_board
    end

    # result # use this for a non-optimized version
    result.reject(&:blocking?) # use this line for an optimized version
  end

  def blocking?
    !Board::NON_BLOCKNG.match?(self)
  end
end
