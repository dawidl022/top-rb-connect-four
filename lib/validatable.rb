require_relative 'util'

module Validatable
  def input_int(prompt,
                error_message = 'Invalid input: please enter an integer number.')
    valid_input = nil
    user_input = nil

    until valid_input
      if user_input
        puts error_message
        put_blank_line
      end

      print prompt
      user_input = gets.chomp
      int_input = user_input.to_i
      valid_input = int_input unless user_input != '0' && int_input == 0
    end

    valid_input
  end

  def input_int_between(prompt, min, max,
    error_message = "Please enter an integer between #{min} and #{max}.")
    user_input = nil
    loop do
      user_input = input_int(prompt, error_message)
      break if user_input >= min && user_input <= max

      puts error_message
      put_blank_line
    end

    user_input
  end

  def ask_yes_no_question(prompt,
    error_message = 'Allowed options are: "y" and "yes" for yes, ' \
    'and "no" and "n" for no (all case-insensitive)')
    answer = nil
    loop do
      print "#{prompt} [Y/n]: "
      answer = gets.chomp.downcase
      break if ['y', 'yes', 'n', 'no'].include?(answer)

      puts error_message
      put_blank_line
    end

    answer == 'y' || answer == 'yes'
  end
end
