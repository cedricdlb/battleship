class Game < ApplicationRecord
  has_many :moves, dependent: :destroy
  belongs_to :player_1, :class_name => "Player", optional: true
  belongs_to :player_2, :class_name => "Player", optional: true
  serialize :player_1_fleet_coords, Array
  serialize :player_2_fleet_coords, Array

  before_save :update_game_state
# before_create :update_game_state
# before_save :update_game_state, if: ["game_state.nil?", :whose_move_changed?,
#                                      :player_1_id_changed?, :player_2_id_changed?,
#                                      :player_1_fleet_status_changed?, :player_2_fleet_status_changed?]

  validates :title, presence: true, uniqueness: true, case_sensitive: false
  validate  :validate_player_1_fleet_coords, if: :player_1_id?
  validate  :validate_player_2_fleet_coords, if: :player_2_id?
  validates :player_1_fleet_status, if: :player_1_id?, numericality: { only_integer: true,
                                                                       greater_than_or_equal_to: 0,
                                                                       less_than_or_equal_to: 0b0111_1111_1111_1111 }
  validates :player_2_fleet_status, if: :player_2_id?, numericality: { only_integer: true,
                                                                       greater_than_or_equal_to: 0,
                                                                       less_than_or_equal_to: 0b0111_1111_1111_1111 }
  validates :whose_move,   if: "player_1_id? && player_2_id?", numericality: { only_integer: true,
                                                                       greater_than_or_equal_to: 0,
                                                                       less_than_or_equal_to:    1,
                                                                       message: "must be 0 or 1" }
  validates :move_counter, if: "player_1_id? && player_2_id?", numericality: { only_integer: true, greater_than_or_equal_to: 0}
  
  SUNK                    = 0b0000_0000_0000_0000
  SUBMARINE_MASK          = 0b0000_0000_0000_0001
  DESTROYER_MASK          = 0b0000_0000_0000_0110
  CRUISER_MASK            = 0b0000_0000_0011_1000
  BATTLESHIP_MASK         = 0b0000_0011_1100_0000
  AIRCRAFT_CARRIER_MASK   = 0b0111_1100_0000_0000

  NUMBER_OF_SHIP_PARTS    = 15

  SHIP_MASKS = [
    SUBMARINE_MASK,
    DESTROYER_MASK,
    CRUISER_MASK,
    BATTLESHIP_MASK,
    AIRCRAFT_CARRIER_MASK,
  ]

  SHIP_NAMES = {
    SUBMARINE_MASK        => "Submarine",
    DESTROYER_MASK        => "Destroyer",
    CRUISER_MASK          => "Cruiser",
    BATTLESHIP_MASK       => "Battleship",
    AIRCRAFT_CARRIER_MASK => "Aircraft Carrier",
  }

  SHIP_COORDS_INDICES = {
    SUBMARINE_MASK        => [0],
    DESTROYER_MASK        => [1..2],
    CRUISER_MASK          => [3..5],
    BATTLESHIP_MASK       => [6..9],
    AIRCRAFT_CARRIER_MASK => [10..14],
  }

  # By default, Player_1 always moves first
  PLAYER_1  = 0
  PLAYER_2  = 1
  NUMBER_OF_PLAYERS = 2

  STATE_WAITING_ALL_PLAYERS_TO_JOIN = 0
  STATE_WAITING_PLAYER_1_TO_JOIN    = 1
  STATE_WAITING_PLAYER_2_TO_JOIN    = 2
  STATE_WAITING_PLAYER_1_TO_MOVE    = 3
  STATE_WAITING_PLAYER_2_TO_MOVE    = 4
  STATE_GAME_OVER_PLAYER_1_WON      = 5
  STATE_GAME_OVER_PLAYER_2_WON      = 6
  STATE_GAME_OVER_TIED_GAME         = 7

  GAME_STATE_MESSAGES = {
    STATE_WAITING_ALL_PLAYERS_TO_JOIN => "Waiting for all players to join",
    STATE_WAITING_PLAYER_1_TO_JOIN    => "Waiting for player 1 to join",
    STATE_WAITING_PLAYER_2_TO_JOIN    => "Waiting for player 2 to join",
    STATE_WAITING_PLAYER_1_TO_MOVE    => "Waiting for player 1 to move",
    STATE_WAITING_PLAYER_2_TO_MOVE    => "Waiting for player 2 to move",
    STATE_GAME_OVER_PLAYER_1_WON      => "Game Over: player 1 won",
    STATE_GAME_OVER_PLAYER_2_WON      => "Game Over: player 2 won",
    STATE_GAME_OVER_TIED_GAME         => "Game Over: tied game",
  }

  X_BOUND = 10
  COORDINATE_MATCHER = /^[A-J]([1-9]|10)$/

  def validate_player_1_fleet_coords
    messages = validate_fleet_coords(player_1_fleet_coords)
   #errors.add(:player_1_fleet_coords, messages) if messages.present?
    messages.each {|message| errors.add(:player_1_fleet_coords, message) }
  end

  def validate_player_2_fleet_coords
    messages = validate_fleet_coords(player_2_fleet_coords)
   #errors.add(:player_2_fleet_coords, messages) if messages.present?
    messages.each {|message| errors.add(:player_2_fleet_coords, message) }
  end

  def validate_fleet_coords(fleet_coords)
    messages = []
    # first check appears to be redundant given its nature as a serialized array: so even when set to nil it seems to be set as an empty array.
    messages << "must be an array of coordinate strings like ['A1', 'B3', 'B4', ...]" unless fleet_coords.is_a?(Array)
    messages << "must have #{NUMBER_OF_SHIP_PARTS} unique coordinate values" unless NUMBER_OF_SHIP_PARTS == fleet_coords.uniq.length
    bc = fleet_coords.select {|e| e !~ COORDINATE_MATCHER} # find bad_coordinates (bc)
    messages << "has these #{bc.length} elements in the wrong format: #{bc} (values should range from A1 to J10)" if bc.present?
    # TODO: more thorough validation of the values within fleet_coords, i.e. that ship parts are contiguous
    messages
  end

  def determine_game_state
    if !player_1_id
      if !player_2_id
        STATE_WAITING_ALL_PLAYERS_TO_JOIN
      else
        STATE_WAITING_PLAYER_1_TO_JOIN
      end
    elsif !player_2_id
      STATE_WAITING_PLAYER_2_TO_JOIN
    elsif PLAYER_1 == whose_move
      if is_fleet_sunk?(player_1_fleet_status)
        if is_fleet_sunk?(player_2_fleet_status)
          STATE_GAME_OVER_TIED_GAME
        else
          STATE_GAME_OVER_PLAYER_2_WON
        end
      elsif is_fleet_sunk?(player_2_fleet_status)
        STATE_GAME_OVER_PLAYER_1_WON
      else
        STATE_WAITING_PLAYER_1_TO_MOVE
      end
    else # PLAYER_2 == whose_move
      if is_fleet_sunk?(player_1_fleet_status)
        STATE_GAME_OVER_PLAYER_2_WON
      else
        STATE_WAITING_PLAYER_2_TO_MOVE
      end
    end
  end

  def game_state
    read_attribute(:game_state) || determine_game_state
  end

  def update_game_state
    self.game_state = determine_game_state
  end

  def game_state_message
    GAME_STATE_MESSAGES[game_state]
  end

  def self.an_intact_fleet_status
    SUBMARINE_MASK | DESTROYER_MASK | CRUISER_MASK | BATTLESHIP_MASK | AIRCRAFT_CARRIER_MASK
  end

  def init_fleet_status
    self.player_1_fleet_status = self.player_2_fleet_status = Game.an_intact_fleet_status
  end

  # Ideally there should be some validation of supplied fleet coordinates:
  # to confirm that all the ship parts are placed,
  # parts of the same ship are consecutive,
  # no two ship parts occupy the same square.
  def init_fleet_coords(params = {})
    self.player_1_fleet_coords = params["player_1_fleet_coords"] || Game.random_fleet_layout
    self.player_2_fleet_coords = params["player_2_fleet_coords"] || Game.random_fleet_layout
  end

 #def initialize(params = {}) # Can't def initialize on ActiveRecord subclasses (http://stackoverflow.com/a/23050424/1399315)
  # These params will probably never be passed in, i should probably remove their use here, it is in create that they get values.
  def init_game(params = {})
    init_fleet_status
    init_fleet_coords(params)
    self.player_1_id = params["player_id"]   || params["player_1_id"]
    self.player_2_id = params["player_2_id"]
    self.whose_move = PLAYER_1
    self.move_counter = 0
  end

  def record_hit!(attack_coords, defending_player_id)
    move_status = {}
    move_status[:message]  = "#{attacker.name} targeted: #{attack_coords} and "  # ...
    move_status[:move_number] = move_counter + 1

    # ship_part_index will be nil if there is no ship at the specified coordinate
    ship_part_index = defender_fleet_coords.index(attack_coords)

    if ship_part_index
      ship_part_mask = 1 << ship_part_index
      ship_mask = get_ship_mask(ship_part_mask)

      # clear the bit in fleet_status which represents the ship_part which has been hit.
      set_defender_fleet_status(defender_fleet_status & ~ship_part_mask)
      update_game_state
      self.save

      move_status[:hit]           = true
      move_status[:ship_part_hit] = SHIP_NAMES[ship_mask]
      move_status[:ship_sunk]     = is_ship_sunk?(defender_fleet_status, ship_mask)
      move_status[:fleet_sunk]    = is_fleet_sunk?(defender_fleet_status)

      sunk_or_hit = move_status[:ship_sunk] ? "sunk" : "hit"
      move_status[:message]      += "#{sunk_or_hit} #{defender.name}'s #{move_status[:ship_part_hit]}!"
      move_status[:message]      += " And destroyed #{defender.name}'s fleet!" if move_status[:fleet_sunk]
    else
      move_status[:hit]           = false
      move_status[:ship_part_hit] = nil
      move_status[:ship_sunk]     = false
      move_status[:fleet_sunk]    = is_fleet_sunk?(defender_fleet_status)
      move_status[:message]      += "missed."
    end
    return move_status
  end

  def attacker
    [player_1, player_2][whose_move]
  end

  def defender
    [player_2, player_1][whose_move]
  end

  def defender_fleet_coords
    [player_2_fleet_coords, player_1_fleet_coords][whose_move]
  end

  def defender_fleet_status
    [player_2_fleet_status, player_1_fleet_status][whose_move]
  end

  def set_defender_fleet_status(fleet_status)
    if players_turn?(player_2_id)
      self.player_1_fleet_status = fleet_status
    else
      self.player_2_fleet_status = fleet_status
    end
  end

  def is_fleet_sunk?(fleet_status)
    SUNK == fleet_status & Game.an_intact_fleet_status
  end

  def is_ship_sunk?(fleet_status, ship_mask)
    SUNK == fleet_status & ship_mask
  end


  def fleet_coords_of_player(player_id)
    player_id == player_1_id ? player_1_fleet_coords : player_2_fleet_coords
  end
 
# def fleet_status_of_player(player_id)
#   player_id == player_1_id ? player_1_fleet_status : player_2_fleet_status
# end
#
# def fleet_status_of_player=(player_id, fleet_status)
#   if player_id == player_1_id
#     self.player_1_fleet_status = fleet_status
#   else
#     self.player_2_fleet_status = fleet_status
#   end
# end

  def ship_part_index_hit(attack_coords, defending_player_id)
    # ship_part_index will be nil if there is no ship at the specified coordinate
    player_fleet_coords = defending_player_id == player_1_id ? player_1_fleet_coords : player_2_fleet_coords
    player_fleet_coords.flatten.index(attack_coords) 
  end

  # Get the full ship mask from the partial ship mask
  # If any ON bits in ship_mask overlap with ship_part_mask, then it is part of the ship
  def get_ship_mask(ship_part_mask)
    SHIP_MASKS.select {|ship_mask| 0 != (ship_mask & ship_part_mask) }.first
  end
  
  def self.get_ship_coords(fleet_coords, ship_mask)
    Array(fleet_coords[*SHIP_COORDS_INDICES[ship_mask]])
  end

  def other_player(this_player_id)
    player_1_id == this_player_id ? player_2 : player_1
  end

  def other_player_id(this_player_id)
    player_1_id == this_player_id ? player_2_id : player_1_id
  end

  def increment_move_counters!
    self.whose_move = (whose_move + 1) % NUMBER_OF_PLAYERS
    self.move_counter += 1
    self.save
  end

  # Could theoretically be adapted to multiple players, using
  # an array of player_ids, where the index is the player_number
  def player_number(player_id)
    player_id == player_1_id ? PLAYER_1 : player_id == player_2_id ? PLAYER_2 : nil
  end

  def player_id_whose_move_it_is
    @player_ids ||= [self.player_1_id, self.player_2_id]
    @player_ids[whose_move]
  end

  def players_turn?(player_id)
    whose_move == player_number(player_id) && [STATE_WAITING_PLAYER_1_TO_MOVE, STATE_WAITING_PLAYER_2_TO_MOVE].include?(game_state)
  end

  # The board is a 10x10 coordinate grid (where x = 1..10, y = A..J).
  # Ships are placed according to the coordinate of their bow, and
  # their stern points either towards the right (horizontal) or down (vertical).
  # First the bow's x coordinate is found as a random number between 0 and 9.
  # If the random x_coord is less than a ship length away from the right edge,
  # then there isn't enough room for the ship to be placed horizontally so close
  # to the edge. In that case, the ship will have to be placed vertically thus
  # the y_coord's maximum bound will need to be 10-ship_length to have room to
  # place it vertically.  Else if the ship is not too close to the right, it may
  # be horizontal, and the y_bound can be 10.  If the random y_coord is less than
  # a ships length away from the bottom, then it will have to be horizontal.
  # If there is no required orientation, it will be randomly vert or horizontal.
  #
  # Ships are placed from largest to smallest, choosing a location & orientation
  # according to the above, and then if any of their coordinates overlap with a
  # previously placed ship, then the ship will get a new random position until a
  # clear location is found.
  def self.random_fleet_layout
    fleet_coords = []
    5.downto(1) do |ship_length|
      #puts "Game.random_fleet_layout ship_length: #{ship_length}"
      begin
        #puts "Game.random_fleet_layout looping to find non conflicting ship position"
        x_coord, y_coord, orientation = Game.random_bow_coords_and_orientation(ship_length)
        ship_coords = Game.ship_vector(x_coord, y_coord, orientation, ship_length)
      end until Game.ship_does_not_intersect_another(ship_coords, fleet_coords)
      #puts "Game.random_fleet_layout set fleet_coords = #{ship_coords + fleet_coords}"
      fleet_coords = ship_coords + fleet_coords
    end
    #puts "Game.random_fleet_layout returning #{fleet_coords}"
    return fleet_coords
  end

  private

  def self.random_bow_coords_and_orientation(ship_length)
    orientation = nil
    edge_zone = X_BOUND - ship_length
    x_coord = rand(X_BOUND) # will be between 0 and 9
    orientation = :vertical if x_coord >= edge_zone
    y_bound = orientation.present? ? edge_zone : X_BOUND
    y_coord = rand(y_bound) # will be between 0 and (y_bound - 1)
    orientation = :horizontal if y_coord >= edge_zone # can't happen if :vertical
    orientation = [:vertical, :horizontal][rand(2)] unless orientation
   #puts "Game.random_bow_coords_and_orientation returning [#{x_coord}, #{y_coord}, #{orientation}]\n"
    return [x_coord, y_coord, orientation]
  end

  def self.ship_vector(x_coord, y_coord, orientation, ship_length)
    vector = []
    (0...ship_length).each do |length_offset|
      x = :vertical   == orientation ? x_coord + 1 : x_coord + 1 + length_offset
      y = :horizontal == orientation ? y_coord : y_coord + length_offset
      vector << "ABCDEFGHIJ"[y] + x.to_s
    end
    #puts "Game.ship_vector (#{x_coord}, #{y_coord}, #{orientation}, #{ship_length}) returning #{vector}"
    return vector
  end

  def self.ship_does_not_intersect_another(ship_coords, fleet_coords)
    (ship_coords - fleet_coords).length == ship_coords.length
  end

end
