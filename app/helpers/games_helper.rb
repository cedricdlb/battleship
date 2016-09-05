module GamesHelper
  def square_position(coordinate, board_image_size)
    each_square_size = board_image_size / 11.0

    # First column and row are legends (A-J, 1-9),
    # so x,y coords are 1-based rather than 0-based
    # i.e. elements in col 1 (e.g. coordinate "F1")
    # will start at square_size * 1, skipping the
    # first column's legend
    letter = coordinate[0].downcase
    y_coord = "Xabcdefghij".index(letter)
    x_coord = coordinate[1..-1].to_i
    left = each_square_size * x_coord 
    top  = each_square_size * y_coord

    return [left, top]
  end

  def peg_position(coordinate, board_image_size, peg_size)
    each_square_size = board_image_size / 11.0

    left, top = square_position(coordinate, board_image_size)

    left += (each_square_size - peg_size)/2
    top  += (each_square_size - peg_size)/2

    return [left, top]
  end

  # ship offsets (to line up the holes in the ships' images with the holes in the board)
  # were calculated based on a board size of 550, which is why they are divided by 550
  # and later multiplied by the actual board size.
  SHIP_OFFSETS = {
  # SHIP_MASK                   => { horizontal: [left, top],         vertical: [left, top] },
    Game::SUBMARINE_MASK        => { horizontal: [0, 0],              vertical: [0, 0] },
    Game::CRUISER_MASK          => { horizontal: [0, 0],              vertical: [0, 2.0/550] },
    Game::BATTLESHIP_MASK       => { horizontal: [0, 0],              vertical: [0, 3.0/550] },
    Game::DESTROYER_MASK        => { horizontal: [3.0/550, 0],        vertical: [1.0/550, -1.0/550] },
    Game::AIRCRAFT_CARRIER_MASK => { horizontal: [2.0/550, -1.0/550], vertical: [0, 2.0/550] },
  }

  def ship_position(coordinate, board_image_size, ship_mask, orientation)
    left, top = square_position(coordinate, board_image_size)
    delta_left, delta_top = SHIP_OFFSETS[ship_mask][orientation] 

    left += delta_left * board_image_size
    top  += delta_top  * board_image_size

    return [left, top]
  end

  def peg_tag(coordinate, color, board_image_size, peg_size, show_position=false)
    left, top = peg_position(coordinate, board_image_size, peg_size)
    pos_text = !show_position ? "" : <<-POSITION
        \n
        <span style="color:blue;">
          <%= left.round %><br><%= top.round %>
        </span>
        \n
    POSITION
    peg_tags = <<-PEGTEXT
      <div class="#{color}-peg" style="left: #{left}px; top: #{top}px;" >#{pos_text}</div>
      <div class="peg-shadow-1" style="left: #{left+peg_size/4.0}px; top: #{top-peg_size/8.0}px;" ></div>
      <div class="peg-shadow-2" style="left: #{left+peg_size/2.0}px; top: #{top-peg_size/4.0}px;" ></div>
    PEGTEXT
    peg_tags.html_safe
  end
end
