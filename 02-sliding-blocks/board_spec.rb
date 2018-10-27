# frozen_string_literal: true

require_relative './board'

describe Board do
  describe '3x3' do
    before do
      Game.width = 3
      Game.height = 3
    end

    let(:target_board) { described_class.target_board }
    let(:unsolvable_board) { described_class.new([2, 1, 3, 4, 5, 6, 7, 8, 0]) }
    let(:board_one) { described_class.new([1, 2, 3, 4, 5, 6, 7, 0, 8]) }
    let(:board_two) { described_class.new([1, 2, 3, 4, 5, 6, 0, 7, 8]) }

    it { expect(target_board).to eq([1, 2, 3, 4, 5, 6, 7, 8, 0]) }

    describe '#solvable?' do
      it { expect(target_board).to be_solvable }
      it { expect(Board.new([1, 2, 3, 4, 5, 6, 7, 0, 8])).to be_solvable }
      it { expect(Board.new([1, 2, 3, 4, 5, 6, 0, 7, 8])).to be_solvable }
      it { expect(Board.new([1, 2, 3, 0, 5, 6, 4, 7, 8])).to be_solvable }
      it { expect(Board.new([1, 2, 3, 5, 0, 6, 4, 7, 8])).to be_solvable }
      it { expect(Board.new([0, 1, 2, 3, 4, 5, 6, 7, 8])).to be_solvable }
      it { expect(Board.new([0, 1, 2, 5, 6, 3, 4, 7, 8])).to be_solvable }
    end

    describe '#manhattan_distance' do
      it { expect(target_board.manhattan_distance).to eq(0) }
      it { expect(board_one.manhattan_distance).to eq(1) }
      it { expect(board_two.manhattan_distance).to eq(2) }
    end

    describe '#turns' do
      it do
        expect(target_board.turns).to eq(
          [
            [1, 2, 3, 4, 5, 6, 7, 0, 8],
            [1, 2, 3, 4, 5, 0, 7, 8, 6]
          ]
        )
      end

      it { expect(target_board.turns[0].path_length).to eq(1) }
      it { expect(target_board.turns[1].path_length).to eq(1) }
      it { expect(target_board.turns[0].parent_dir).to eq(:right) }
      it { expect(target_board.turns[1].parent_dir).to eq(:down) }
      it { expect(target_board.turns[0].parent).to eq(target_board) }
      it { expect(target_board.turns[1].parent).to eq(target_board) }
    end

    describe 'eql?' do
      let(:board_one_another_path_length) do
        r = board_one.dup
        r.path_length = 2

        r
      end

      it { expect(target_board).to be_eql(target_board) }
      it { expect(target_board).not_to be_eql(board_one) }
      it { expect(board_one).to be_eql(board_one_another_path_length) }
    end
  end

  describe '4x4' do
    before do
      Game.width = 4
      Game.height = 4
    end

    let(:target_board) { described_class.target_board }

    describe 'solvable?' do
      it { expect(target_board).to be_solvable }
    end

    describe '#manhattan_distance' do
      it { expect(target_board.manhattan_distance).to eq(0) }
    end
  end
end
