require_relative "util"
require_relative "validatable"

class Menu
  include Validatable

  def initialize(options)
    validate_options(options)
    @options = options
  end

  def display_menu(columns = 1)
    option_index = 0

    @options.each do |option|
      option_index += 1
      print_formatted_with_ending(option, option_index, columns)
    end

    put_blank_line if option_index % columns != 0
  end

  def take_input(prompt = "Enter an option:")
    input_option(prompt, @options.map { |option| bracketed(option) })
  end

  private

  def validate_options(options)
    unless options.is_a?(Array)
      raise ArgumentError, "An array must be passed to initialize"
    end

    unless options.length > 0
      raise ArgumentError, "The options array must have at least 1 option"
    end

    unless options.all? do |option|
      option.is_a?(Array) && option.length > 0 && option.length <= 3
      end
      raise ArgumentError, "Each option must be an array of size 1, 2 or 3"
    end

    unless options.all? do |option|
        option[1..].all? { |element| element.is_a?(Integer) }
      end
      raise ArgumentError, "The 2nd and 3rd options elements must be integers"
    end

    unless options.all? do |option|
        option[1..].all? do |element|
          element >= 0 && element <= option[0].to_s.length
        end
      end
      raise ArgumentError, "The 2nd and 3rd options elements elements must" \
            "be between 0 and the length of the key"
    end
  end

  def max_option_length
    @options.reduce(0) do |max_length, option|
      option[0].length > max_length ? option[0].length : max_length
    end
  end

  def print_formatted_with_ending(option, option_index, columns)
    formatted_option = format_option(option)

    ending =
      if option_index % columns == 0
        "\n"
      else
        " " * (max_option_length + 4 - formatted_option.length)
      end

    print formatted_option + ending
  end

  def format_option(option)
    text = option[0].to_s

    if option.length == 1
      "[#{text}]"
    elsif option.length == 2
      "[#{text[...option[1]]}]#{text[option[1]..]}"
    else
      "#{text[...option[1]]}" \
          "[#{text[option[1]...option[2]]}]" \
          "#{text[option[2]..]}"
    end
  end

  def bracketed(option)
    text = option[0].to_s

    if option.length == 1
      "#{text}"
    elsif option.length == 2
      "#{text[...option[1]]}"
    else
      "#{text[option[1]...option[2]]}"
    end
  end
end
