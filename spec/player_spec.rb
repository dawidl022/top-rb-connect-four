require_relative '../lib/player'
require_relative 'util'

RSpec.describe Player do
  include Util

  subject(:player1) { described_class.new(:X, :red) }
  let(:player2) { described_class.new(:O, :yellow) }

  describe '#piece' do
    it 'is the one given at initialisation' do
      expect(player1.piece).to eq(:X)
      expect(player2.piece).to eq(:O)
    end
  end

  describe '#colour' do
    it 'is the one given at initialisation' do
      expect(player1.colour).to eq(:red)
      expect(player2.colour).to eq(:yellow)
    end
  end

  describe '#move' do
    context 'when a single digit number is entered' do
      before do
        allow(player1).to receive(:gets).and_return('5')
      end

      it 'prints a prompt' do
        expect { player1.move }.to output('Enter column number: ').to_stdout
      end

      it 'returns the entered in number' do
        mute_io
        expect(player1.move).to eq(5)
      end
    end

    context 'when a two digit number is entered' do
      before do
        mute_io
        allow(player1).to receive(:gets).and_return('10')
      end

      it 'returns the entered in number' do
        expect(player1.move(1, 10)).to eq(10)
      end
    end

    context 'when a non-integer is entered followed by a valid integer' do
      before do
        allow(player1).to receive(:gets).and_return('aaab', '4')
      end

      it 'prints an error message' do
        expect { player1.move }.to output(
          /Invalid input. Please enter an integer between 0 and 6./
        ).to_stdout
      end
    end

    context 'invalid input when the min and max are non-default' do
      before do
        allow(player1).to receive(:gets).and_return('aaab', '6', '17')
      end

      it 'prints an error message' do
        expect { player1.move(10, 20) }.to output(
          /Invalid input. Please enter an integer between 10 and 20./
        ).to_stdout
      end

      it 'returns the valid input' do
        mute_io
        expect(player1.move(10, 20)).to eq(17)
      end
    end
  end
end
