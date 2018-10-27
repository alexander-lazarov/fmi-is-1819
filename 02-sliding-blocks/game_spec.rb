# frozen_string_literal: true

require_relative './game'

describe Game do
  describe '3x3' do
    before do
      Game.width = 3
      Game.height = 3
    end

    it { expect(Game).to respond_to(:width) }
    it { expect(Game).to respond_to(:height) }
    it { expect(Game.size).to eq(9) }

    it { expect(Game.solve([1, 2, 3, 4, 5, 6, 7, 8, 0])).to eq([]) }
    it { expect(Game.solve([1, 2, 3, 4, 5, 6, 7, 0, 8])).to eq(%i[left]) }
    it { expect(Game.solve([1, 2, 3, 4, 5, 6, 0, 7, 8])).to eq(%i[left left]) }
    it { expect(Game.solve([1, 2, 3, 0, 5, 6, 4, 7, 8])).to eq(%i[up left left]) }
    it { expect(Game.solve([1, 2, 3, 5, 0, 6, 4, 7, 8])).to eq(%i[right up left left]) }
    it { expect(Game.solve([0, 1, 2, 3, 4, 5, 6, 7, 8])).to eq(%i[left up right up left left down right right up left down down left up up right right down left left up]) }
    it { expect(Game.solve([0, 1, 2, 5, 6, 3, 4, 7, 8])).to eq(%i[left left up right right up left left]) }
    it { expect(Game.solve([5, 2, 8, 4, 1, 7, 0, 3, 6])).to eq(%i[down left left up right down left down right right up up left down left up right down down left up up]) }
    it { expect(Game.solve([1, 2, 3, 7, 4, 5, 8, 6, 0])).to eq(%i[right right down left left up]) }
    it { expect(Game.solve([4, 0, 2, 3, 5, 7, 8, 1, 6])).to eq(%i[up left down right right up left up right down left down right up left left down right up left up]) }
    it { expect(Game.solve([1, 2, 3, 4, 5, 6, 8, 7, 0])).to eq(false) }
  end

  # describe '4x4' do
  #   before do
  #     Game.width = 4
  #     Game.height = 4
  #   end

  #   it { expect(Game.solve([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0])).to eq([]) }
  #   it { expect(Game.solve([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 0, 15])).to eq([:left]) }
  #   it { expect(Game.solve([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])).not_to eq(false) }
  # end
end
