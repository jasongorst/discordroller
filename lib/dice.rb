class Dice
  attr_reader :number, :sides, :modifier, :results, :total

  def initialize(number, sides, modifier)
    @number = number
    @sides = sides
    @modifier = modifier
    roll
  end

  def roll
    @results = Array.new(@number) { rand(1..@sides) }
    @total = @results.inject(:+) + @modifier
  end

end
