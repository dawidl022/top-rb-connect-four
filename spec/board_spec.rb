require 'colorize'
require_relative '../lib/board'

RSpec.describe Board do
  subject(:board) { described_class.new({ X: :red, O: :yellow }) }

  it 'should start out with 7 empty arrays' do
    expect(board.board).to eq(Array.new(7, []))
  end

  describe '#place' do
    context 'in empty column' do
      it 'adds the piece to the column' do
        board.place(:X, 0)
        expect(board.board[0]).to eq([:X])
      end
    end

    context 'in a non-empty column' do
      it 'adds the piece to the end of the column' do
        board.place(:X, 6)
        board.place(:O, 6)
        expect(board.board[6]).to eq([:X, :O])
      end
    end

    context 'in a non-existant column' do
      it 'raises an exception' do
        expect { board.place(:X, 7) }.to raise_error(
          IndexError, 'Such a column does not exist on the board'
        )
      end
    end

    context 'in a full column' do
      it 'raises an exception' do
        6.times do
          board.place(:X, 3)
        end

        expect { board.place(:X, 3) }.to raise_error(
          ArgumentError, 'Cannot append to full column'
        )
      end
    end

    context 'when board has different dimensions than the default' do
      pending
    end
  end

  describe '#draw_board' do
    context 'when game starts' do
      it 'board is drawn empty' do
        expect(board.draw_board).to eq(<<~ASCIIART
          │───│───│───│───│───│───│───|
          │   │   │   │   │   │   │   │
          │───│───│───│───│───│───│───│
          │   │   │   │   │   │   │   │
          │───│───│───│───│───│───│───│
          │   │   │   │   │   │   │   │
          │───│───│───│───│───│───│───│
          │   │   │   │   │   │   │   │
          │───│───│───│───│───│───│───│
          │   │   │   │   │   │   │   │
          │───│───│───│───│───│───│───│
          │   │   │   │   │   │   │   │
          │───│───│───│───│───│───│───│
        ASCIIART
        )
      end
    end

    context 'when some moves have been made' do
      it 'draws board with correctly coloured blocks on board' do
        board.place(:X, 6)
        board.place(:O, 6)
        board.place(:X, 3)
        board.place(:O, 1)

        template = <<~ASCIIART
          │───│───│───│───│───│───│───|
          │   │   │   │   │   │   │   │
          │───│───│───│───│───│───│───│
          │   │   │   │   │   │   │   │
          │───│───│───│───│───│───│───│
          │   │   │   │   │   │   │   │
          │───│───│───│───│───│───│───│
          │   │   │   │   │   │   │   │
          │───│───│───│───│───│───│───│
          │   │   │   │   │   │   │%s│
          │───│───│───│───│───│───│───│
          │   │%s│   │%s│   │   │%s│
          │───│───│───│───│───│───│───│
        ASCIIART
        expected_board = template % [
          '   '.colorize(background: :yellow),
          '   '.colorize(background: :yellow),
          '   '.colorize(background: :red),
          '   '.colorize(background: :red)
        ]

        expect(board.draw_board).to eq(expected_board)
      end
    end

    context 'when given different colours and some moves have been made'

    context 'when board has different dimensions than the default' do
      pending
    end
  end

  describe '#game_over?' do
    context 'when the board is empty' do
      it { should_not be_game_over }
    end

    context 'when there is no four connected' do
      before do
        board.place(:X, 6)
        board.place(:O, 6)
        board.place(:X, 3)
        board.place(:O, 1)
      end

      it { should_not be_game_over }
    end

    context 'when a four is connected in a column' do
      context 'in first column' do
        before do
          4.times do
            board.place(:X, 0)
          end
        end

        it { should be_game_over }
      end

      context 'in last column' do
        before do
          4.times do
            board.place(:X, 6)
          end
        end

        it { should be_game_over }
      end

      context 'as the second player' do
        before do
          4.times do
            board.place(:O, 3)
          end
        end

        it { should be_game_over }
      end
    end

    context 'when a four is connected in a row' do
      context 'in bottom row' do
        before do
          4.times do |column|
            board.place(:O, column)
          end
        end

        it { should be_game_over }
      end

      context 'in a middle row' do
        it "is expected to be game over only when there are 4 of same colour" do
          3.times do
            (2..5).each do |column|
              if column.even?
                board.place(:X, column)
              else
                board.place(:O, column)
              end
            end
          end

          expect(board).to_not be_game_over

          4.times do |column|
            board.place(:O, column)
          end

          expect(board).to be_game_over
        end
      end

      context 'in top row' do
        before do
          5.times do
            (2..5).each do |column|
              if column.even?
                board.place(:X, column)
              else
                board.place(:O, column)
              end
            end
          end

          4.times do |column|
            board.place(:O, column)
          end
        end

        it { should be_game_over }
      end
    end

    context 'when a four is connected diagonally' do
      context 'in the shape of a backward slash' do
        it "is expected to be game over only when there are 4 of same colour" do
          (0..2).each do |i|
            (3 - i).times do
              board.place(:O, i)
            end
          end

          expect(board).to_not be_game_over

          4.times do |i|
            board.place(:X, i)
          end

          expect(board).to be_game_over
        end
      end

      context 'in the shape of a forward slash' do
        it "is expected to be game over only when there are 4 of same colour" do
          6.downto(4) do |i|
            (i - 3).times do
              board.place(:O, i)
            end
          end
          expect(board).to_not be_game_over

          (3..6).each do |i|
            board.place(:X, i)
          end

          expect(board).to be_game_over
        end
      end
    end
  end

  describe '#winner' do
    context 'when there is no winner' do
      it 'returns nil' do
        board.place(:X, 6)
        board.place(:O, 6)
        board.place(:X, 3)
        board.place(:O, 1)

        expect(board.winner).to be_nil
      end
    end

    context 'when there is a winner' do
      context 'when :O wins in a row' do
        it 'returns the piece of the winner' do
          4.times do |column|
            board.place(:O, column)
          end

          expect(board.winner).to eq(:O)
        end
      end

      context 'when :X wins diagonally in a backward slash' do
        it 'returns the piece of the winner' do
          (0..2).each do |i|
            (3 - i).times do
              board.place(:O, i)
            end
          end

          4.times do |i|
            board.place(:X, i)
          end

          expect(board.winner).to eq(:X)
        end
      end

      context 'when :O wins diagonally in a forward slash' do
        it 'returns the piece of the winner' do
          6.downto(4) do |i|
            (i - 3).times do
              board.place(:X, i)
            end
          end

          (3..6).each do |i|
            board.place(:O, i)
          end

          expect(board.winner).to eq(:O)
        end
      end

      context 'when :X wins in a column' do
        it 'returns the piece of the winner' do
          4.times do
            board.place(:X, 6)
          end

          expect(board.winner).to eq(:X)
        end
      end
    end
  end

  describe "#column_full?" do
    context "when column is empty" do
      it { should_not be_column_full(0) }
    end

    context "when column is not full" do
      before do
        board.place(:X, 0)
        board.place(:X, 0)
        board.place(:X, 0)
        board.place(:X, 0)
        board.place(:X, 0)
      end

      it { should_not be_column_full(0) }
    end

    context "when column is full" do
      before do
        board.place(:X, 0)
        board.place(:X, 0)
        board.place(:X, 0)
        board.place(:X, 0)
        board.place(:X, 0)
        board.place(:X, 0)
      end

      it { should be_column_full(0) }
    end
  end
end
