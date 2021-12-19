class Board
  attr_reader :board

  # TODO: Parametrise these dimensions
  NUMBER_OF_COLUMNS = 7
  NUMBER_OF_ROWS = 6
  GOAL = 4
  BOARD_TEMPLATE = <<~ASCIIART
    │───│───│───│───│───│───│───|
    │%s│%s│%s│%s│%s│%s│%s│
    │───│───│───│───│───│───│───│
    │%s│%s│%s│%s│%s│%s│%s│
    │───│───│───│───│───│───│───│
    │%s│%s│%s│%s│%s│%s│%s│
    │───│───│───│───│───│───│───│
    │%s│%s│%s│%s│%s│%s│%s│
    │───│───│───│───│───│───│───│
    │%s│%s│%s│%s│%s│%s│%s│
    │───│───│───│───│───│───│───│
    │%s│%s│%s│%s│%s│%s│%s│
    │───│───│───│───│───│───│───│
  ASCIIART
  EMPTY = '   '

  def initialize(piece_colours)
    @board = Array.new(NUMBER_OF_COLUMNS) { Array.new }
    @piece_colours = piece_colours
  end

  def place(piece, column)
    if column >= NUMBER_OF_COLUMNS
      raise IndexError, 'Such a column does not exist on the board'
    end

    if @board[column].length >= NUMBER_OF_ROWS
      raise ArgumentError, 'Cannot append to full column'
    end

    @board[column] << piece
  end

  def draw_board
    BOARD_TEMPLATE % board_format
  end

  def game_over?
    !!winner
  end

  def winner
    winner_piece = nil

    @piece_colours.each do |piece, _colour|
      winner_piece ||= goal_in_row?(piece)
      winner_piece ||= goal_in_column?(piece)
      winner_piece ||= goal_in_diagonal?(piece)

      break if winner_piece
    end

    winner_piece
  end

  private

  def board_format
    formats = []
    (0...NUMBER_OF_ROWS).each do |j|
      (0...NUMBER_OF_COLUMNS).each do |i|
        piece_in_square = @board[i][5 - j]
        if piece_in_square.nil?
          formats << EMPTY
        else
          formats << '   '.colorize(background: @piece_colours[piece_in_square])
        end
      end
    end
    formats
  end

  def goal_in_row?(piece)
    goal_reached = false

    (0...NUMBER_OF_ROWS).each do |row|
      current_count = 0
      max_count = 0

      @board.each_index do |column|
        square = @board[column][row]

        if square == piece
          current_count += 1
          max_count = current_count if current_count > max_count
        else
          current_count = 0
        end
      end

      goal_reached = max_count >= GOAL
      break if goal_reached
    end

    piece if goal_reached
  end

  def goal_in_column?(piece)
    goal_reached = false

    @board.each do |column|
      goal_reached = goal_in_array?(column, piece)
      break if goal_reached
    end

    piece if goal_reached
  end

  def goal_in_diagonal?(piece)
    goal_in_forward_diagonal?(piece) || goal_in_backwards_diagonal?(piece)
  end

  def goal_in_forward_diagonal?(piece)
    goal_reached = false
    (0..11).each do |max|
      x = 0 # column
      y = max # row
      diagonal = []
      while (x >= 0  && y >= 0 && x < NUMBER_OF_COLUMNS && y < NUMBER_OF_ROWS)
        diagonal << @board[x][y]
        x += 1
        y -= 1
      end

      goal_reached = goal_in_array?(diagonal, piece)
      break if goal_reached
    end
    piece if goal_reached
  end

  def goal_in_backwards_diagonal?(piece)
    goal_reached = false
    (0..6).each do |start|
      (start..6).each do |diff|
        x = start
        y = 5 - diff
        diagonal = []
        while (x >= 0  && y >= 0 && x < NUMBER_OF_COLUMNS && y < NUMBER_OF_ROWS)
          diagonal << @board[x][y]
          x += 1
          y += 1
        end

        goal_reached = goal_in_array?(diagonal, piece)
        break if goal_reached
      end
      break if goal_reached
    end
    piece if goal_reached
  end

  def goal_in_array?(array, piece)
    current_count = 0
    max_count = 0

    array.each do |square|
      if square == piece
        current_count += 1
        max_count = current_count if current_count > max_count
      else
        current_count = 0
      end
    end

    max_count >= GOAL
  end
end
