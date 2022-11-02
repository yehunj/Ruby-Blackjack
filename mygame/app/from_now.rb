module FromNow
  @@callbacks ||= nil
  @@last_tick ||= -1

  def self.reset(last_tick = -1)
    @@last_tick = last_tick
    @@callbacks = nil
  end

  def self.tick(t = $args.tick_count)
    if t < @@last_tick # clear callbacks after $gtk.reset
      FromNow.reset
      return
    end

    @@last_tick = t
    return unless list = @@callbacks&.delete(t)

    i = 0
    n = list.size
    while i < n
      list[i].call
      i += 1
    end
  end

  def from_now(&blk)
    n = round

    if n.zero?
      blk.call
    else
      @@callbacks ||= Hash.new { |hash, tick| hash[tick] = [] }
      @@callbacks[@@last_tick + n] << blk
    end
  end

  # just so you can do "5.frames.from_now { }"
  def frames() = self
end

Numeric.include FromNow
