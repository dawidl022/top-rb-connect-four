module Util
  def mute_io(object = subject, methods = %i[puts print])
    methods.each { |method| allow(object).to receive(method) }
  end

  def drawing_game(board)
    board.place(:O, 0)
    board.place(:O, 0)
    board.place(:X, 0)
    board.place(:O, 0)
    board.place(:X, 0)
    board.place(:O, 0)

    board.place(:O, 1)
    board.place(:O, 1)
    board.place(:X, 1)
    board.place(:O, 1)
    board.place(:X, 1)
    board.place(:O, 1)

    board.place(:X, 2)
    board.place(:X, 2)
    board.place(:O, 2)
    board.place(:X, 2)
    board.place(:X, 2)
    board.place(:O, 2)

    board.place(:X, 3)
    board.place(:X, 3)
    board.place(:O, 3)
    board.place(:X, 3)
    board.place(:O, 3)
    board.place(:X, 3)

    board.place(:O, 4)
    board.place(:O, 4)
    board.place(:X, 4)
    board.place(:X, 4)
    board.place(:X, 4)
    board.place(:O, 4)

    board.place(:X, 5)
    board.place(:O, 5)
    board.place(:X, 5)
    board.place(:O, 5)
    board.place(:X, 5)
    board.place(:O, 5)

    board.place(:O, 6)
    board.place(:X, 6)
    board.place(:O, 6)
    board.place(:X, 6)
    board.place(:X, 6)
    board.place(:O, 6)
  end
end
