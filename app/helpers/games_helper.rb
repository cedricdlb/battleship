module GamesHelper
  def peg_position(coordinate, board_image_size)
    # TODO: Adapt to variable board size
    first_hole_top=59
    first_hole_left=55
    letter = coordinate[0].downcase
    y_coord = "abcdefghij".index(letter)
    x_coord = coordinate[1..-1].to_i - 1 # -1 for 0-based sequence

    left = first_hole_left + 50.5*x_coord
    left += (4.5-x_coord)*((8.5-y_coord)/3)

    top  = first_hole_top  + 50.5*y_coord
    top  -=   y_coord  *2 if y_coord <  5
    top  -= (9-y_coord)*2 if y_coord >= 5

    return [left, top]
  end
end
