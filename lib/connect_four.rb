require_relative 'player'
require_relative 'board'
require_relative 'util'
require_relative 'validatable'

class ConnectFour
  include Validatable

  def initialize
    @player1 = Player.new(:X, :red)
    @player2 = Player.new(:O, :yellow)
    @board = Board.new({
      @player1.piece => @player1.colour,
      @player2.piece => @player2.colour,
    })
  end

  def play_game
    turn_number = 1
    current_player = nil

    until @board.winner
      player_number = turn_number % 2 == 1 ? 1 : 2
      current_player = player_number == 1 ? @player1 : @player2

      puts @board.draw_board
      puts "Player #{player_number}, " \
           "enter the column number you wish to place a disc:"

      make_move(current_player)

      turn_number += 1
    end

    puts @board.draw_board
    print_winner(player_number)

    play_again?
  end

  private

  def play_again?
    ask_yes_no_question("Do you want to play again?")
  end

  def print_winner(winner)
    puts "GAME OVER! Player #{winner} wins!"
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
