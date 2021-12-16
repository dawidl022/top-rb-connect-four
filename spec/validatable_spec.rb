require_relative '../lib/validatable'

RSpec.describe Validatable do
  REPEAT_BAD_INPUT_TIMES = 3
  ERROR_MESSAGE = "Invalid input: please enter an integer number.\n\n"
  DEFAULT_NUMBER = 3

  describe '#input_int' do
    let(:dummy_class) { Class.new { extend Validatable } }

    before do
      allow(dummy_class).to receive(:gets).and_return("#{DEFAULT_NUMBER}\n")
    end

    it 'prints the message given' do
      message = 'Enter integer: '
      expect { dummy_class.input_int(message) }.to output(message).to_stdout
    end

    shared_examples_for 'accepting integer' do |number|
      before do
        allow(dummy_class).to receive(:gets).and_return("#{number}\n")
      end

      it 'does not print error' do
        expect { dummy_class.input_int('') }.to_not output(
          'Invalid input: please enter an integer number.'
        ).to_stdout
      end

      it 'returns the integer' do
        expect(dummy_class.input_int('')).to eq(number.to_i)
      end
    end

    shared_examples_for 'invalid input' do |input_value|
      before do
        allow(dummy_class).to receive(:gets).and_return(
          *["#{input_value}\n"] * REPEAT_BAD_INPUT_TIMES << "#{DEFAULT_NUMBER}\n"
        )
      end

      it 'prints error' do
        expect { dummy_class.input_int('') }.to output(
          /#{ERROR_MESSAGE}/
        ).to_stdout
      end

      it 'reprompts for input until it receives a correct one' do
        expect { dummy_class.input_int('') }.to output(
          ERROR_MESSAGE * REPEAT_BAD_INPUT_TIMES
        ).to_stdout
      end

      it 'returns the last input' do
        allow(dummy_class).to receive(:puts)
        expect(dummy_class.input_int('')).to eq(DEFAULT_NUMBER)
      end
    end

    describe 'given' do
      context 'positive integer' do
        it_behaves_like 'accepting integer', DEFAULT_NUMBER
      end

      context 'zero' do
        it_behaves_like 'accepting integer', 0
      end

      context 'negative integers' do
        it_behaves_like 'accepting integer', -120
      end

      context 'empty input' do
        it_behaves_like 'invalid input', ''
      end

      context 'other characters with leading digits' do
        it_behaves_like 'accepting integer', '123asdf'
      end

      context 'accept other characters without leading digits' do
        it_behaves_like 'invalid input', 'edf'
      end
    end
  end
end
