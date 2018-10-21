# frozen_string_literal: true

require './board'

describe Board do
  describe '.initial_board' do
    it { expect(described_class.initial_board(2)).to eq('LL RR') }
  end

  describe '.target_board' do
    it { expect(described_class.target_board(2)).to eq('RR LL') }
  end

  describe '#turns' do
    it do
      expect(described_class.new('L R').turns).to contain_exactly(
        ' LR',
        'LR '
      )
    end

    it { expect(described_class.new('R L').turns).to contain_exactly }
    it { expect(described_class.new('RL ').turns).to contain_exactly('R L') }
    it { expect(described_class.new(' LR').turns).to contain_exactly('RL ') }
    it { expect(described_class.new('LR ').turns).to contain_exactly(' RL') }
    it do
      expect(described_class.new('LL RR').turns).to contain_exactly(
        ' LLRR',
        'L LRR',
        'LLR R',
        'LLRR '
      )
    end
    it do
      expect(described_class.new('LLL RRR').turns).to contain_exactly(
        'LL LRRR',
        'L LLRRR',
        'LLLR RR',
        'LLLRR R'
      )
    end

    it 'sets the parent' do
      parent = described_class.new('LR ')
      child = parent.turns[0]
      expect(child.parent).to eq(parent)
    end
  end
end
