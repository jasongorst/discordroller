class DiceParser

  PATTERN = /^(?<num>\d+)?[dD](?<sides>\d+)(?<mod>[+\-]\d+)?$/

  def self.parse(input)
    if (match = input.match(PATTERN))
      num = Integer(match[:num]) rescue 1
      sides = Integer(match[:sides])
      mod = Integer(match[:mod]) rescue 0
      return num, sides, mod
    else
      raise ArgumentError, "Invalid die notation: #{input}"
    end
  end
end
