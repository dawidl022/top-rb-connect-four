require_relative 'validatable'
require_relative 'util'

class Player
  include Validatable

  attr_reader :piece, :colour

  def initialize(piece, colour)
    @piece = piece
    @colour = colour
  end

  def move(min = 0, max = 6)
    prompt = 'Enter column number: '
    error_message = 'Invalid input.' \
      " Please enter an integer between #{min} and #{max}."
    input_int_between(prompt, min, max, error_message)
  end
end
