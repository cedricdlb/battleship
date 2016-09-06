module GamesHelper
  def square_position(coordinate, board_size)
    each_square_size = board_size / 11.0

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

  def peg_position(coordinate, board_size, peg_size)
    each_square_size = board_size / 11.0

    left, top = square_position(coordinate, board_size)

    left += (each_square_size - peg_size)/2
    top  += (each_square_size - peg_size)/2

    return [left, top]
  end

  def peg_tag(coordinate, color, board_size, peg_size, show_position=false)
    left, top = peg_position(coordinate, board_size, peg_size)
    pos_text = !show_position ? "" : <<-POSITION
        \n
        <span style="color:blue;">
          <%= left.round %><br><%= top.round %>
        </span>
        \n
    POSITION
    peg_tags = <<-PEGTEXT
      <div class="#{color}-peg" style="left: #{left}px; top: #{top}px;" >#{pos_text}</div>
      <div class="peg-shadow" style="left: #{left+peg_size/4.0}px; top: #{top-peg_size/4.0}px;" ></div>
    PEGTEXT
    peg_tags.html_safe
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

  def ship_position(coordinate, board_size, ship_mask, orientation)
    left, top = square_position(coordinate, board_size)
    delta_left, delta_top = SHIP_OFFSETS[ship_mask][orientation] 

    left += delta_left * board_size
    top  += delta_top  * board_size

    return [left, top]
  end

  SHIP_DATA = {
    Game::DESTROYER_MASK        => { horizontal: {size: "100x50", image: "ship.Destroyer.horizontal.png"},
                                     vertical:   {size: "50x100", image: "ship.Destroyer.vertical.png"} },
    Game::SUBMARINE_MASK        => { horizontal: {size: "150x50", image: "ship.Submarine.horizontal.png"},
                                     vertical:   {size: "50x150", image: "ship.Submarine.vertical.png"} },
    Game::CRUISER_MASK          => { horizontal: {size: "150x50", image: "ship.Cruiser.horizontal.png"},
                                     vertical:   {size: "50x150", image: "ship.Cruiser.vertical.png"} },
    Game::BATTLESHIP_MASK       => { horizontal: {size: "200x50", image: "ship.Battleship.horizontal.png"},
                                     vertical:   {size: "50x200", image: "ship.Battleship.vertical.png"} },
    Game::AIRCRAFT_CARRIER_MASK => { horizontal: {size: "250x50", image: "ship.AirCraftCarrier.horizontal.png"},
                                     vertical:   {size: "50x250", image: "ship.AirCraftCarrier.vertical.png"} },
  }

  def ship_tag(coordinate, board_size, ship_mask, orientation)
    left, top = ship_position(coordinate, board_size, ship_mask, orientation)
    ship_image = SHIP_DATA[ship_mask][orientation][:image] 
    image_tag(ship_image,
              :class => "ship",
              :size => SHIP_DATA[ship_mask][orientation][:size],
              :style => "left:#{left}px; top: #{top}px;",
              :alt => "image at #{coordinate} of #{ship_image}",
    )
  end

  def position_ships(game, player_id, board_size)
   #fleet_coords = Game.random_fleet_layout
    fleet_coords = game.fleet_coords_of_player(player_id)
    ship_tags = ""
    Game::SHIP_MASKS.each do |ship_mask|
      first_coord, second_coord = Game.get_ship_coords(fleet_coords, ship_mask)
      first_coord_y  = first_coord[0]
      second_coord_y = second_coord ? second_coord[0] : "SINGLE_LENGTH_SHIP"
      orientation = first_coord_y  == second_coord_y ? :horizontal : :vertical
      ship_tags << ship_tag(first_coord, board_size, ship_mask, orientation).to_s
    end
    ship_tags.html_safe
  end

 #create_table "moves", force: :cascade do |t|
 #  t.integer  "game_id"
 #  t.integer  "player_id"
 #  t.integer  "move_number"
 #  t.string   "attack_coords"
 #  t.string   "ship_part_hit"
 #  t.boolean  "hit"
 #  t.boolean  "ship_sunk"
 #  t.boolean  "fleet_sunk"
 #  t.text     "message"
 #  t.datetime "created_at",    null: false
 #  t.datetime "updated_at",    null: false
 #end
  def display_pegs(game, player_id, board_size, peg_size)
    moves = game.moves
    peg_tags = ""
    attack_moves = []
    moves.each do |move|
      if move.player_id == player_id
        # save for later display on targetting board, TODO
        attack_moves << move
      else
        # display on defense board
        color = move.hit ? "red" : "white"
        peg_tags << peg_tag(move.attack_coords, color, board_size, peg_size).to_s
      end
    end
    peg_tags.html_safe
  end
end
