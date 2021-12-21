require_relative '../lib/connect_four'
require_relative '../lib/board'
require_relative '../lib/player'
require_relative 'util'
require 'stringio'

RSpec.describe ConnectFour do
  include Util

  describe "#play_game" do
    subject(:connect_four) { described_class.new }
    let(:board) { Board.new({ X: :red, O: :yellow }) }

    before do
      allow(connect_four.instance_variable_get(:@player1))
      .to receive(:move).and_return(0, 1, 2, 3)
      allow(connect_four.instance_variable_get(:@player2))
      .to receive(:move).and_return(0, 6, 6, 4)
      allow(connect_four).to receive(:gets).and_return('y')
      mute_io(subject, [:print])
    end

    context "when called" do
      it "prints an empty board first" do
        expect(connect_four).to receive(:puts).with(board.draw_board).once
        expect(connect_four).to receive(:puts).at_least(:once)
        connect_four.play_game
      end

      it "prompts the first player for their turn" do
        expect { connect_four.play_game }.to output(
          /Player 1, enter the column number you wish to place a disc:/
        ).to_stdout
      end
    end

    context "when a row number is typed in" do
      before do
        board.place(:X, 0)
      end

      it "prints a board with the player's move" do
        expect(connect_four).to receive(:puts).with(board.draw_board).once
        expect(connect_four).to receive(:puts).at_least(:once)
        connect_four.play_game
      end

      it "prompts the second player for their turn" do
        expect { connect_four.play_game }.to output(
          /Player 2, enter the column number you wish to place a disc:/
        ).to_stdout
      end
    end

    context "when two row numbers are typed in" do
      before do
        board.place(:X, 0)
        board.place(:O, 0)
      end
      it "prints a board with two different pieces placed" do
        expect(connect_four).to receive(:puts).with(board.draw_board).once
        expect(connect_four).to receive(:puts).at_least(:once)
        connect_four.play_game
      end
    end

    context 'when player tries to place in full column' do
      before do
        allow(connect_four.instance_variable_get(:@player1))
        .to receive(:move).and_return(0, 0, 0, 0, 1, 2, 2, 3)
        allow(connect_four.instance_variable_get(:@player2))
        .to receive(:move).and_return(0, 0, 0, 6, 5, 4, 3)
      end

      it 'resumes the game' do
        expect { connect_four.play_game }.to output(
          /GAME OVER! Player 1 wins!/
        ).to_stdout
      end

      it 'displays a message and lets the player choose again' do
        expect { connect_four.play_game }.to output(
          /You cannot place a disc in that column, it is already full!/
        ).to_stdout
      end
    end

    context 'when there is a winner' do
      context 'when player 1 wins' do
        before do
          board.place(:X, 0)
          board.place(:O, 0)
          board.place(:X, 1)
          board.place(:O, 6)
          board.place(:X, 2)
          board.place(:O, 6)
          board.place(:X, 3)
        end

        it "displays the final board" do
          expect(connect_four).to receive(:puts).with(board.draw_board).once
          expect(connect_four).to receive(:puts).at_least(:once)
          connect_four.play_game
        end

        it "the game prints GAME OVER and the winner" do
          expect { connect_four.play_game }.to output(
            /GAME OVER! Player 1 wins!/
          ).to_stdout
        end
      end

      it "returns true if the players want to play another round" do
        mute_io
        expect(connect_four.play_game).to be true
      end

      it "returns false if the players don't want to play another round" do
        allow(connect_four).to receive(:gets).and_return('n')
        mute_io

        expect(connect_four.play_game).to be false
      end

      context 'when player 2 wins' do
        before do
          allow(connect_four.instance_variable_get(:@player1))
            .to receive(:move).and_return(0, 1, 4, 6)
          allow(connect_four.instance_variable_get(:@player2))
            .to receive(:move).and_return(2, 2, 2, 2)
        end

        it "the game prints GAME OVER and the winner" do
          expect { connect_four.play_game }.to output(
            /GAME OVER! Player 2 wins!/
          ).to_stdout
        end
      end

      context 'when the board is full and there is no winner'
    end
  end
end
