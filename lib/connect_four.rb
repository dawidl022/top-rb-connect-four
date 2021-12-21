require_relative 'player'
require_relative 'board'
require_relative 'util'
require_relative 'menu'
require_relative 'validatable'

class ConnectFour
  include Validatable

  TITLE = <<~TITLE
     a88888b.                                                dP       88888888b
    d8'   `88                                                88       88
    88        .d8888b. 88d888b. 88d888b. .d8888b. .d8888b. d8888P    a88aaaa    .d8888b. dP    dP 88d888b.
    88        88'  `88 88'  `88 88'  `88 88ooood8 88'  `""   88       88        88'  `88 88    88 88'  `88
    Y8.   .88 88.  .88 88    88 88    88 88.  ... 88.  ...   88       88        88.  .88 88.  .88 88
     Y88888P' `88888P' dP    dP dP    dP `88888P' `88888P'   dP       dP        `88888P' `88888P' dP
  TITLE

  def initialize
    @player1 = Player.new(:X, :red)
    @player2 = Player.new(:O, :yellow)
    @main_menu = Menu.new([[:Play, 1], [:Quit, 1]])
    @board = Board.new({
      @player1.piece => @player1.colour,
      @player2.piece => @player2.colour,
    })
  end

  def play_game
    turn_number = 1
    current_player = nil

    until @board.game_over?
      player_number = turn_number % 2 == 1 ? 1 : 2
      current_player = player_number == 1 ? @player1 : @player2

      puts @board.draw_board
      puts "Player #{player_number}, " \
           "enter the column number you wish to place a disc:"

      make_move(current_player)

      turn_number += 1
    end

    puts @board.draw_board
    print_winner([@player1, @player2])

    play_again?
  end

  def show_main_menu
    loop do
      puts TITLE
      put_blank_line

      @main_menu.display_menu

      menu_option = @main_menu.take_input
      break if menu_option == 1

      loop do
        play_again = play_game
        @board.clear_board
        break unless play_again
      end
      put_blank_line
    end
  end

  private

  def play_again?
    ask_yes_no_question("Do you want to play again?")
  end

  def print_winner(players)
    output =
      if @board.winner
        winner = players.find_index { |player| player.piece == @board.winner }
        "GAME OVER! Player #{winner + 1} wins!"
      else
        "GAME OVER! Good job, the game ended in a draw!"
      end

    puts output
  end

  def make_move(current_player)
    desired_move = current_player.move

    while @board.column_full?(desired_move)
      puts 'You cannot place a disc in that column, it is already full!'
      put_blank_line
      desired_move = current_player.move
    end

    @board.place(current_player.piece, desired_move)
  end
end

if __FILE__ == $PROGRAM_NAME
  ConnectFour.new.show_main_menu
end
