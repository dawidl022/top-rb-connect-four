require_relative '../lib/validatable'
require_relative 'util'

RSpec.describe Validatable do
  include Util

  REPEAT_BAD_INPUT_TIMES = 3
  ERROR_MESSAGE = "Invalid input: please enter an integer number.\n\n"
  DEFAULT_NUMBER = 3
  let(:dummy_class) { Class.new { extend Validatable } }

  describe '#input_int' do
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

    context 'when given a custom error message' do
      before do
        allow(dummy_class).to receive(:gets)
          .and_return('aa', "#{DEFAULT_NUMBER}")
      end
      error_message = "You did not enter a valid integer, try again!"

      it 'prints the error message when invalid input is given' do
        expect { dummy_class.input_int('', error_message) }.to output(
          "#{error_message}\n\n"
        ).to_stdout
      end
    end
  end

  describe "#input_int_between" do
    context 'when correct value is entered first time round' do
      before { allow(dummy_class).to receive(:gets).and_return('7') }

      it 'returns the input value' do
        expect(dummy_class.input_int_between('', 1, 10)).to eq(7)
      end
    end

    context 'when an incorrect value is entered first time round' do
      before { allow(dummy_class).to receive(:gets).and_return('102', '7') }

      it 'displays the default error message' do
        expect { dummy_class.input_int_between('', 1, 10) }.to output(
          "Please enter an integer between 1 and 10.\n\n"
        ).to_stdout
      end

      it 'returns the corrected input value' do
        mute_io(dummy_class)
        expect(dummy_class.input_int_between('', 1, 10)).to eq(7)
      end
    end

    context 'when a custom error message is supplied' do
      before { allow(dummy_class).to receive(:gets).and_return('102', '7') }

      error_message = "Out of range!"

      it 'displays the error message when input is invalid' do
        expect { dummy_class.input_int_between('', 1, 10, error_message) }
          .to output("#{error_message}\n\n").to_stdout
      end
    end
  end

  describe "#ask_yes_no_question" do
    let(:question) { "Do you like ruby?" }
    before { allow(dummy_class).to receive(:gets).and_return('y') }

    shared_examples_for 'answer is yes' do
      it 'returns true' do
        mute_io(dummy_class)
        expect(dummy_class.ask_yes_no_question(question)).to be true
      end
    end

    shared_examples_for 'answer is no' do
      it 'returns false' do
        mute_io(dummy_class)
        expect(dummy_class.ask_yes_no_question(question)).to be false
      end
    end

    context 'when y is supplied as input' do
      before do
        allow(dummy_class).to receive(:gets).and_return('y')
      end

      it_behaves_like 'answer is yes'
    end

    context 'when yes is supplied as input' do
      before do
        allow(dummy_class).to receive(:gets).and_return('yes')
      end

      it_behaves_like 'answer is yes'
    end

    context 'when YES is supplied as input' do
      before do
        allow(dummy_class).to receive(:gets).and_return('YES')
      end

      it_behaves_like 'answer is yes'
    end

    context 'when N is supplied as input' do
      before do
        allow(dummy_class).to receive(:gets).and_return('N')
      end

      it_behaves_like 'answer is no'
    end

    context 'when No is supplied as input' do
      before do
        allow(dummy_class).to receive(:gets).and_return('No')
      end

      it_behaves_like 'answer is no'
    end

    context 'when no is supplied as input' do
      before do
        allow(dummy_class).to receive(:gets).and_return('no')
      end

      it_behaves_like 'answer is no'
    end

    context 'when invalid input is supplied first, then valid input' do
      before do
        allow(dummy_class).to receive(:gets).and_return('yup', 'y')
      end

      error_message = 'Allowed options are: "y" and "yes" for yes, ' \
        'and "no" and "n" for no (all case-insensitive)'

      it 'displays the default error message' do
        expect(dummy_class).to receive(:puts).with(error_message).once
        expect(dummy_class).to receive(:puts).once
        mute_io(dummy_class, [:print])
        dummy_class.ask_yes_no_question('')
      end

      it_behaves_like 'answer is yes'
    end

    context 'when supplied with a custom error message' do
      error_message = "Only y/yes/n/no are accepted!"

      it 'displays the error message when input is invalid' do
        allow(dummy_class).to receive(:gets).and_return('blah', 'n')
        expect(dummy_class).to receive(:puts).with(error_message).once
        expect(dummy_class).to receive(:puts).once
        mute_io(dummy_class, [:print])
        dummy_class.ask_yes_no_question('', error_message)
      end
    end

    it 'prints the prompt' do
      expect { dummy_class.ask_yes_no_question(question) }.to output(
        "#{question} [Y/n]: "
      ).to_stdout
    end
  end

  describe "#input_option" do
    context "when given an empty options collection" do
      it "raises an error" do
        expect { dummy_class.input_option('', []) }.to raise_error(
          ArgumentError, "At least 1 option must be provided!"
        )
      end
    end

    context "when given a non-empty options collection" do
      before do
        allow(dummy_class).to receive(:gets).and_return('high scores')
      end

      options = ['Play', 'High scores', 'Quit']

      it 'prints the given prompt' do
        expect { dummy_class.input_option('Enter option:', options) }.to output(
          'Enter option: '
        ).to_stdout
      end

      it 'returns the index of the chosen option (case-insensitive)' do
        expect(dummy_class.input_option('', options))
        .to eq(1)
      end
    end

    context 'when given bad input twice by the user' do
      before do
        allow(dummy_class).to receive(:gets).and_return('p', 'pla', 'play')
      end

      it 'prints an error message twice' do
        expect(dummy_class).to receive(:puts).with(
          "Invalid input. Enter one of the following: ['Play', 'Quit']"
        ).twice
        dummy_class.input_option('', ['Play', 'Quit'])
      end

      it 'reprompts the user twice' do
        mute_io(dummy_class, [:puts])
        expect(dummy_class).to receive(:print).with('Enter option: ')
          .exactly(3).times
        dummy_class.input_option('Enter option:', ['Play', 'Quit'])
      end

      it 'returns the valid response' do
        mute_io(dummy_class)
        expect(dummy_class.input_option('', ['Play', 'Quit'])).to eq(0)
      end
    end
  end
end
