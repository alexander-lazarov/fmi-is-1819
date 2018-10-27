# frozen_string_literal: true

class PriorityQueue
  def initialize
    @queue = {}
  end

  def empty?
    @queue.empty?
  end

  def enqueue(element, priority)
    @queue[priority] ||= []
    @queue[priority] << element
  end

  def dequeue
    return nil if empty?

    top_priority = @queue.keys.min
    result = @queue[top_priority].delete_at(0)

    @queue.delete(top_priority) if @queue[top_priority].empty?

    result
  end
end
