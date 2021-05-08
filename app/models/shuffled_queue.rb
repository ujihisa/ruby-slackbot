# frozen_string_literal: true

class ShuffledQueue
  def initialize(xs)
    @orig_xs = xs.freeze
    reset
  end

  def pop
    @xs.pop
  end

  def reset
    @xs = @orig_xs.shuffle
  end

  def self.inspect
    <<~EOS
    Use this like
      @sq = ShuffledQueue.new(%w[ruby vim].product(%w[clojure scala]))
      @sq.pop #=> ['vim', 'clojure']

    * ShuffledQueue.new([...])
    * ShuffledQueue#pop()
    * ShuffledQueue#reset()
    EOS
  end
end
