class Game < ApplicationRecord
  has_many :moves, dependent: :destroy
  belongs_to :player_1, :class_name => "Player"#, :foreign_key => 'player_1_id'
  belongs_to :player_2, :class_name => "Player"#, :foreign_key => 'player_2_id'
  serialize :player_1_fleet_coords, Array
  serialize :player_2_fleet_coords, Array

  validates :title, presence: true, uniqueness: true, case_sensitive: false
  # TODO: validation method for player_1_fleet_coords & player_2_fleet_coords
  
  SUNK                    = 0b0000_0000_0000_0000
  SUBMARINE_MASK          = 0b0000_0000_0000_0001
  DESTROYER_MASK          = 0b0000_0000_0000_0110
  CRUISER_MASK            = 0b0000_0000_0011_1000
  BATTLESHIP_MASK         = 0b0000_0011_1100_0000
  AIRCRAFT_CARRIER_MASK   = 0b0111_1100_0000_0000

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

  NUMBER_OF_PLAYERS = 2

  def init_fleet_status
    self.player_1_fleet_status = self.player_2_fleet_status = SUBMARINE_MASK | DESTROYER_MASK | CRUISER_MASK | BATTLESHIP_MASK | AIRCRAFT_CARRIER_MASK
  end

  # Ideally there should be some validation of supplied fleet coordinates:
  # to confirm that all the ship parts are placed,
  # parts of the same ship are consecutive,
  # no two ship parts occupy the same square.
  def init_fleet_coords(params = {})
    self.player_1_fleet_coords = params["player_1_fleet_coords"] || random_fleet_layout
    self.player_2_fleet_coords = params["player_2_fleet_coords"] || random_fleet_layout
  end

 #def initialize(params = {}) # Can't def initialize on ActiveRecord subclasses (http://stackoverflow.com/a/23050424/1399315)
  # These params will probably never be passed in, i should probably remove their use here, it is in create that they get values.
  def init_game(params = {})
    init_fleet_status
    init_fleet_coords(params)
    self.player_1_id = params["player_id"]   || params["player_1_id"]
    self.player_2_id = params["player_2_id"]
    self.whose_move = 0 # player_1 is 0, player_2 is 1, so starts as player_1's move
  end

  def record_hit!(attack_coords, defending_player_id)
    move_status = {}
    defender_fleet_coords = defending_player_id == player_1_id ?  player_1_fleet_coords  :  player_2_fleet_coords
    defender_fleet_status = defending_player_id == player_1_id ? "player_1_fleet_status" : "player_2_fleet_status"

    # ship_part_index will be nil if there is no ship at the specified coordinate
    ship_part_index = defender_fleet_coords.flatten.index(attack_coords)

    if ship_part_index
      ship_part_mask = 1 << ship_part_index
      ship_mask = get_ship_mask(ship_part_mask)

      # clear the bit in fleet_status which represents the ship_part which has been hit.
     #          defender_fleet_status  &= ~ship_part_mask # This did not alter self, e.g. self.player_1_fleet_status
      self.send(defender_fleet_status+"=", self.send(defender_fleet_status) & ~ship_part_mask)
      self.save

      move_status[:hit]           = true
      move_status[:ship_part_hit] = SHIP_NAMES[ship_mask]
     #move_status[:ship_sunk]     = SUNK == defender_fleet_status & ship_mask
     #move_status[:fleet_sunk]    = SUNK == defender_fleet_status
      move_status[:ship_sunk]     = SUNK == self.send(defender_fleet_status) & ship_mask
      move_status[:fleet_sunk]    = SUNK == self.send(defender_fleet_status)

      attacker = other_player(defending_player_id).name
      defender = Player.find(defending_player_id).name
      sunk_or_hit = move_status[:ship_sunk] ? "sunk" : "hit"
      move_status[:message]  = "#{attacker} #{sunk_or_hit} #{defender}'s #{move_status[:ship_part_hit]}!"
      move_status[:message] += " And destroyed #{defender}'s fleet!" if move_status[:fleet_sunk]
    else
      move_status[:hit]           = false
    end
    return move_status
  end

  # TODO: Employ and test these methods in record_hit method
  def defender_fleet_status
    players_turn?(player_2_id) ? player_1_fleet_status : player_2_fleet_status
  end

  def defender_fleet_status=(fleet_status)
    if players_turn?(player_2_id)
      self.player_1_fleet_status = fleet_status
    else
      self.player_2_fleet_status = fleet_status
    end
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
  # If any ON bits in ship_mask overlap with ship_part_mask, then its part of the ship
  def get_ship_mask(ship_part_mask)
    SHIP_MASKS.select {|ship_mask| 0 != (ship_mask & ship_part_mask) }.first
  end

  def other_player(this_player_id)
    player_1_id == this_player_id ? player_2 : player_1
  end

  def other_player_id(this_player_id)
    player_1_id == this_player_id ? player_2_id : player_1_id
  end

  def increment_whose_turn_it_is!
    self.whose_move = (whose_move + 1) % NUMBER_OF_PLAYERS
    self.save
  end

  # Could theoretically be adapted to multiple players, using
  # an array of player_ids, where the index is the player_number
  def player_number(player_id)
    player_id == player_1_id ? 0 : player_id == player_2_id ? 1 : nil
  end

  def player_id_whose_move_it_is
    @player_ids ||= [self.player_1_id, self.player_2_id]
    @player_ids[whose_move]
  end

  def players_turn?(player_id)
    whose_move == player_number(player_id)
  end

  private

  SAMPLE_LAYOUTS = [
    ["a1",   "b1", "b2",   "c1", "c2", "c3",   "d1", "d2", "d3", "d4",   "e1", "e2", "e3", "e4", "e5" ],
    ["b2",   "b4", "c4",   "d1", "d2", "d3",   "i4", "i5", "i6", "i7",   "e9", "f9", "g9", "h9", "i9" ]
 #  [["a1"],   ["b1", "b2"],   ["c1", "c2", "c3"],   ["d1", "d2", "d3", "d4"],   ["e1", "e2", "e3", "e4", "e5"] ],
 #  [["b2"],   ["b4", "c4"],   ["d1", "d2", "d3"],   ["i4", "i5", "i6", "i7"],   ["e9", "f9", "g9", "h9", "i9"] ]
  ]
    
  SAMPLE_LAYOUTS_2 = [
    [[:submarine,         ["a1"]],
     [:destroyer,         ["b1", "b2"]],
     [:cruiser,           ["c1", "c2", "c3"]],
     [:battleship,        ["d1", "d2", "d3", "d4"]],
     [:air_craft_carrier, ["e1", "e2", "e3", "e4", "e5"]]
    ],
    [[:submarine,         ["b2"]],
     [:destroyer,         ["b4", "c4"]],
     [:cruiser,           ["d1", "d2", "d3"]],
     [:battleship,        ["i4", "i5", "i6", "i7"]],
     [:air_craft_carrier, ["e9", "f9", "g9", "h9", "i9"]]
    ]
  ]
  # Stub, not very random yet
  def random_fleet_layout
    SAMPLE_LAYOUTS[rand(SAMPLE_LAYOUTS.size)]
  end


end
