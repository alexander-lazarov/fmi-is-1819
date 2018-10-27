require 'set'
require_relative './priority_queue'
require_relative './board'

class Game
  class << self
    attr_accessor :width
    attr_accessor :height

    def size
      @width * @height
    end

    def solve(input)
      initial_board = Board.new(input)

      return false unless initial_board.solvable?

      visited_nodes = Set.new

      queue = PriorityQueue.new
      queue.enqueue(Board.new(initial_board), initial_board.manhattan_distance)

      solution = nil

      loop do
        current = queue.dequeue

        visited_nodes << current

        if current == Board.target_board
          solution = current
          break
        end

        turns = current.turns

        turns.each do |turn|
          next if visited_nodes.include?(turn)

          queue.enqueue(turn, turn.path_length + turn.manhattan_distance)
        end
      end

      solution_path = []

      while solution
        solution_path << solution.parent_dir
        solution = solution.parent
      end

      solution_path.compact.reverse
    end
  end
end
