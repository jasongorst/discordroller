# frozen_string_literal: true

require 'discordrb'
require 'dotenv'
require_relative './lib/roller'

Dotenv.load

def nickname_or_name(event)
  if event.user.nickname.nil?
    event.user.name
  else
    event.user.nickname
  end
end

# Instantiate a `CommandBot`. We have to set a `prefix` here, The character that triggers command execution.
bot = Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'], prefix: '/'

# Test commands
bot.command(:user, description: 'Prints your current nickname or user name.') do |event|
  # Commands send whatever is returned from the block to the channel. This allows for compact commands like this,
  # but you have to be aware of this so you don't accidentally return something you didn't intend to.
  # To prevent the return value to be sent to the channel, you can just return `nil`.
  nickname_or_name(event)
end

# Commands
bot.command(:coin, description: 'Flips a coin.') do |event|
  flip = rand < 0.5 ? 'Heads' : 'Tails'
  event << "**#{nickname_or_name(event)}** flips a coin."
  event << " It's #{flip}!"
end

bot.command(:roll, description: 'Rolls some dice.', usage: 'roll number_of_dice, [difficulty] [explode]', min_args: 1, max_args: 3) do |event, number, difficulty, explode|
  # convert number to int
  number = number.to_i

  # do 10s explode?
  explode_words = %w[explode exp ex e]
  explode = explode_words.include?(explode)

  # set default difficulty if missing, convert to int
  difficulty = 6 if difficulty.nil?
  difficulty = difficulty.to_i

  # make the roll
  roll = Roller.new(number, difficulty, explode)

  # Determine result
  result = if roll.success?
             'Success'
           elsif roll.botch?
             'Botch'
           else
             'Failure'
           end

  event << "**#{nickname_or_name(event)}** rolls some dice."
  event << roll.rolls.to_s
  event << "Successes: #{roll.successes}"
  event << "Failures: #{roll.failures}"
  event << "Result: #{result}!"
end

bot.run
