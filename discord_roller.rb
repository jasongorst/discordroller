# frozen_string_literal: true
require 'bundler/setup'
require 'abbrev'
require 'discordrb'
require 'dotenv'
require_relative './lib/dice'
require_relative './lib/dice_parser'
require_relative './lib/roller'

Dotenv.load '.env.production'

DEFAULT_DIFFICULTY = 6
MAX_DICE = 20

def display_name(event)
  event.user.nickname || event.user.name
end

# Instantiate a `CommandBot`. We have to set a `prefix` here, The character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'], prefix: '/'

# Commands
bot.command(:coin, description: 'Flips a coin.') do |event|
  flip = %w[Heads Tails].sample
  event << "**#{display_name(event)}** flips a coin."
  event << "Result: #{flip}!"
end

bot.command(:dice, description: 'Rolls some dice.', usage: 'dice [number]d[sides][+/-modifier]', min_args: 1, max_args: 1) do |event, d|
  # parse dice string
  num, sides, mod = DiceParser::parse(d)
  dice = Dice.new(num, sides, mod)

  mod_str = (mod == 0 ? '' : sprintf('%+d', mod))

  event << "**#{display_name(event)}** rolls #{num}d#{sides}#{mod_str}."
  event << "Rolls: #{dice.results}"
  event << "Total: #{dice.total}"
end

bot.command(:roll, description: 'Rolls some dice for WoD.', usage: 'roll [number of dice] [difficulty] [explode?]', min_args: 1, max_args: 3) do |event, number, difficulty, explode|
  # convert number to int
  number = number.to_i

  # set default difficulty if missing, else convert to int
  difficulty = difficulty.nil? ? DEFAULT_DIFFICULTY : difficulty.to_i

  # do 10s explode?
  explode = Abbrev.abbrev(["explode"]).keys.include?(explode)

  if number > MAX_DICE
    event << "That's too many dice. Try #{MAX_DICE} or less."
  elsif number < 1
    event << "I need a number of dice to roll."
  elsif difficulty > 10
    event << "You can't roll higher than 10."
  elsif difficulty < 2
    event << "The difficulty has to be at least 2."
  else
    # make the roll
    roll = Roller.new(number, difficulty, explode)

    # Determine result
    result = if roll.botch?
               '_Botch!_'
             elsif roll.failure?
               'Failure'
             else
               "#{roll.check} Success#{roll.check == 1 ? '' : 'es'}"
             end

    event << "**#{display_name(event)}** rolls some dice."
    event << "Rolls: #{roll.rolls.to_s}"
    event << "Result: #{result}"
  end
end

bot.run
