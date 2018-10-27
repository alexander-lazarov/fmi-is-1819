# frozen_string_literal: true

require 'scanf'
require_relative './game.rb'

size = scanf('%d').first
width = height = Math.sqrt(size + 1)
raise ArgumentError, 'Invalid size' unless width == width.to_i

Game.width = width.to_i
Game.height = height.to_i

board = scanf('%d' * (size + 1))

solutuon = Game.solve(board)

if solutuon
  puts solutuon.length
  solutuon.each { |turn| puts turn }
else
  puts 'Not solvable' unless solutuon
end
