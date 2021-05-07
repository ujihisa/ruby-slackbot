require 'test_helper'

class ShuffledQueueTest < ActiveSupport::TestCase
  test 'everything' do
    shuffled_queue = ShuffledQueue.new([1, 2, 3])

    x = shuffled_queue.pop
    assert_includes([1, 2, 3], x)

    x = shuffled_queue.pop
    assert_includes([1, 2, 3], x)

    x = shuffled_queue.pop
    assert_includes([1, 2, 3], x)

    x = shuffled_queue.pop
    assert_nil(x)

    shuffled_queue.reset
    x = shuffled_queue.pop
    assert_includes([1, 2, 3], x)
  end
end
