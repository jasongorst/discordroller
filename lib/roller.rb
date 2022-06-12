class Roller
  attr_reader :number, :difficulty, :rolls

  def initialize(number, difficulty, explode)
    @number = number
    @difficulty = difficulty
    @rolls = []

    n = @number
    until n == 0
      @rolls << rand(1..10)
      n -= 1 unless (explode && @rolls.last == 10)
    end
  end

  def successes
    @rolls.select {|r| r >= @difficulty}.count
  end

  def failures
    @rolls.select {|r| r == 1}.count
  end

  def check
    self.successes - self.failures
  end

  def success?
    self.check > 0
  end

  def failure?
    self.check == 0
  end

  def botch?
    self.check < 0
  end
end
