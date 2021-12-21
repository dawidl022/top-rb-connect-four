require_relative '../lib/menu'
require_relative 'util'

RSpec.describe Menu do
  include Util

  describe "#validate_options" do
    context "is not passed an array" do
      it "raises error with appropriate message" do
        expect { described_class.new("play") }.to raise_error(
          ArgumentError, "An array must be passed to initialize"
        )
      end
    end

    context "is passed an empty array" do
      it "raises error with appropriate message" do
        expect { described_class.new([]) }.to raise_error(
          ArgumentError, "The options array must have at least 1 option"
        )
      end
    end

    context "options array is not made of arrays with key value pairs" do
      it "raises error with appropriate message" do
        expect { described_class.new([[1, 2, 3], 2]) }.to raise_error(
          ArgumentError, "Each option must be an array of size 1, 2 or 3"
        )
      end
    end

    context "The option value elements are not integers" do
      it "raises error with appropriate message" do
        expect { described_class.new([[:play, 'a']]) }
        .to raise_error(
          ArgumentError, "The 2nd and 3rd options elements must be integers"
        )
      end
    end

    context "value arrays contain arrays have elements outside of key length" do
      it "raises error with appropriate message" do
        expect { described_class.new([[:play, 0, 10]]) }
        .to raise_error(
          ArgumentError, "The 2nd and 3rd options elements elements must" \
            "be between 0 and the length of the key"
        )
      end
    end
  end

  describe "#display_menu" do
    context "when no argument is passed" do
      context "when no bracket range is specified" do
        subject(:menu) { described_class.new([[:Play], [:Quit]]) }

        it "displays the whole option in brackets, all options in one column" do
          expect { menu.display_menu }.to output(
            "[Play]\n[Quit]\n"
          ).to_stdout
        end
      end

      context "when a bracket range is just one character" do
        subject(:menu) { described_class.new([[:Play, 1], [:Quit, 1]]) }

        it "displays the first letter in brackets, all options in one column" do
          expect { menu.display_menu }.to output(
            "[P]lay\n[Q]uit\n"
          ).to_stdout
        end
      end

      context "when a bracket range is more than 1 character from beginning" do
        subject(:menu) { described_class.new([[:Play, 2], [:Quit, 3]]) }

        it "displays the letters in brackets, all options in one column" do
          expect { menu.display_menu }.to output(
            "[Pl]ay\n[Qui]t\n"
          ).to_stdout
        end
      end

      context "when bracket is a character in the middle" do
        subject(:menu) { described_class.new([[:Play, 1, 2], [:Quit, 2, 3]]) }

        it "displays a middle letter in brackets, all options in one column" do
          expect { menu.display_menu }.to output(
            "P[l]ay\nQu[i]t\n"
          ).to_stdout
        end
      end

      context "when bracket is more than 1 character in the middle" do
        subject(:menu) { described_class.new([[:Play, 0, 2], [:Quit, 1, 3]]) }

        it "displays a middle letter in brackets, all options in one column" do
          expect { menu.display_menu }.to output(
            "[Pl]ay\nQ[ui]t\n"
          ).to_stdout
        end
      end
    end

    context 'when 2 is passed as the columns argument' do
      subject(:menu) do
        described_class.new([
          [:Play], [:Quit], [:Option3], [:Option4], [:Option5]
        ])
      end

      it "displays 2 menu items per column, aligned by width" do
        expect { menu.display_menu(2) }.to output(
          "[Play]     [Quit]\n" \
          "[Option3]  [Option4]\n" \
          "[Option5]  \n"
        ).to_stdout
      end
    end

    context 'when 3 is passed as the columns argument' do
      subject(:menu) do
        described_class.new([
          [:Play], [:Quit], [:Option3], [:Option4], [:Option5]
        ])
      end

      it "displays 3 menu items per column, aligned by width" do
        expect { menu.display_menu(3) }.to output(
          "[Play]     [Quit]     [Option3]\n" \
          "[Option4]  [Option5]  \n"
        ).to_stdout
      end
    end
  end

  describe "#take_input" do
    subject(:menu) { described_class.new([[:Play], [:Quit]]) }

    context 'when given no arguments' do
      before do
        allow(menu).to receive(:gets).and_return("quit")
      end

      it 'prints a default prompt' do
        expect { menu.take_input }.to output(
          "Enter an option: "
        ).to_stdout
      end

      context 'when first option is chosen' do
        before do
          allow(menu).to receive(:gets).and_return("PLAY")
        end

        it 'returns the index of the chosen option (case-insensitive)' do
          mute_io
          expect(menu.take_input).to eq(0)
        end
      end

      context 'when second option is chosen' do
        it 'returns the index of the chosen option (case-insensitive)' do
          mute_io
          expect(menu.take_input).to eq(1)
        end
      end

    end
  end
end
