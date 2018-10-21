# frozen_string_literal: true

require './board'

class Frogs
  def initialize(size)
    @size = size

    @initial_board = Board.initial_board(size)
    @target_board = Board.target_board(size)
  end

  def solve
    to_visit = [].push(@initial_board)
    found = nil

    loop do
      current_board = to_visit.pop
      turns = current_board.turns

      next if turns.empty?

      if turns.include?(@target_board)
        found = turns[turns.index(@target_board)]

        break
      end

      to_visit += turns
    end

    current_route = []

    while found
      current_route << found
      found = found.parent
    end

    current_route.reverse
  end
end
