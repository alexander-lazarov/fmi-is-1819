# frozen_string_literal: true

require './frogs'

describe Frogs do
  it do
    expect(Frogs.new(1).solve).to(
      eq([
        'L R',
        ' LR',
        'RL ',
        'R L'
      ]).or eq([
        'L R',
        'LR ',
        ' RL',
        'R L'
      ])
    )
  end

  it do
    expect(Frogs.new(2).solve).to(
      eq([
        'LL RR',
        'LLR R',
        'L RLR',
        ' LRLR',
        'RL LR',
        'RLRL ',
        'RLR L',
        'R RLL',
        'RR LL'
      ]).or eq([
        'LL RR',
        'L LRR',
        'LRL R',
        'LR RL',
        ' RLRL',
        'R LRL',
        'RRL L',
        'RR LL',
      ])
    )
  end
end
