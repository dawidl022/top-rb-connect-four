require_relative '../lib/connect_four'
require_relative '../lib/board'
require_relative '../lib/player'
require_relative '../lib/menu'
require_relative 'util'

RSpec.describe ConnectFour do
  include Util

  def stub_player_input(subject)
    allow(subject.instance_variable_get(:@player1))
    .to receive(:move).and_return(0, 1, 2, 3)
    allow(subject.instance_variable_get(:@player2))
    .to receive(:move).and_return(0, 6, 6, 4)
  end

  describe "#play_game" do
    subject(:connect_four) { described_class.new }
    let(:board) { Board.new({ X: :red, O: :yellow }) }

    before do
      stub_player_input(connect_four)
      allow(subject).to receive(:gets).and_return('y')
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

      context 'when there is a draw' do
        let(:board) { instance_double(Board) }

        before do
          allow(board).to receive(:game_over?).and_return(true)
          allow(board).to receive(:winner).and_return(nil)
          allow(board).to receive(:draw_board)
          connect_four.instance_variable_set(:@board, board)
        end

        it "the game prints GAME OVER and declares a draw" do
          expect { connect_four.play_game }.to output(
            /GAME OVER! Good job, the game ended in a draw!/
          ).to_stdout
        end
      end

      context 'when the board is full and there is no winner'
    end
  end

  describe "#main_menu" do
    subject(:connect_four) { described_class.new }
    let(:menu) { instance_double(Menu) }

    before do
      mute_io
      allow(menu).to receive(:display_menu)
      allow(menu).to receive(:take_input).and_return(0, 1)
      allow(connect_four).to receive(:gets).and_return('y', 'n')
      connect_four.instance_variable_set(:@main_menu, menu)
      stub_player_input(connect_four)
    end


    it "prints an ASCII art title" do
      title = <<~TITLE
         a88888b.                                                dP       88888888b
        d8'   `88                                                88       88
        88        .d8888b. 88d888b. 88d888b. .d8888b. .d8888b. d8888P    a88aaaa    .d8888b. dP    dP 88d888b.
        88        88'  `88 88'  `88 88'  `88 88ooood8 88'  `""   88       88        88'  `88 88    88 88'  `88
        Y8.   .88 88.  .88 88    88 88    88 88.  ... 88.  ...   88       88        88.  .88 88.  .88 88
         Y88888P' `88888P' dP    dP dP    dP `88888P' `88888P'   dP       dP        `88888P' `88888P' dP
      TITLE

      expect(connect_four).to receive(:puts).with(title).once
      expect(connect_four).to receive(:puts).at_least(:once)
      connect_four.show_main_menu
    end

    it "calls the menu to be displayed" do
      expect(menu).to receive(:display_menu)
      connect_four.show_main_menu
    end

    it "starts the game when p is entered" do
      expect(connect_four).to receive(:play_game)
      connect_four.show_main_menu
    end

    it "quits when q is entered" do
      allow(menu).to receive(:take_input).and_return(1)
      expect(connect_four).to_not receive(:play_game)
      connect_four.show_main_menu
    end

    context 'when players choose to play another game' do
      it 'starts another game' do
        allow(connect_four).to receive(:play_game).and_return(true, false)
        expect(connect_four).to receive(:play_game).twice
        connect_four.show_main_menu
      end

      it "resets the board after each game" do
        expect(connect_four.instance_variable_get(:@board))
          .to receive(:clear_board).twice
        connect_four.show_main_menu
      end
    end
  end
end
