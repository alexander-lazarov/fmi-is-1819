# frozen_string_literal: true

require_relative './priority_queue'

describe PriorityQueue do
  let(:q) { PriorityQueue.new }

  context 'when empty' do
    it { expect(q).to be_empty }
    it { expect(q.dequeue).to eq(nil) }
  end

  context 'when many elements with the same priority' do
    before do
      q.enqueue('el1', 1)
      q.enqueue('el2', 1)
      q.enqueue('el3', 1)
    end

    it 'returns the values', :aggregate_failures do
      expect(q).not_to be_empty
      expect(q.dequeue).to eq('el1')
      expect(q.dequeue).to eq('el2')
      expect(q.dequeue).to eq('el3')
      expect(q.dequeue).to eq(nil)
      expect(q).to be_empty
    end
  end

  context 'when elements with different priority' do
    before do
      q.enqueue('el1', 2)
      q.enqueue('el2', 3)
      q.enqueue('el3', 4)
      q.enqueue('el4', 1)
    end

    it 'returns the values', :aggregate_failures do
      expect(q).not_to be_empty
      expect(q.dequeue).to eq('el4')
      expect(q.dequeue).to eq('el1')
      expect(q.dequeue).to eq('el2')
      expect(q.dequeue).to eq('el3')
      expect(q).to be_empty
    end
  end
end
