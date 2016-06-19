class Game < ApplicationRecord
  has_many :moves, dependent: :destroy
  # has_many :players, through: :moves
  has_one :player_1
  has_one :player_2

  validates :title, presence: true, uniqueness: true, case_sensitive: false
  
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

  def initialize(params)
    player_1_fleet_status = SUBMARINE_MASK | DESTROYER_MASK | CRUISER_MASK | BATTLESHIP_MASK | AIRCRAFT_CARRIER_MASK
    player_2_fleet_status = player_1_fleet_status
    # Ideally there should be some validation of supplied fleet coordinates:
    # to confirm that all the ship parts are placed,
    # parts of the same ship are consecutive,
    # no two ship parts occupy the same square.
    player_1_fleet_coords = params["player_1_fleet_coords"] || random_fleet_layout
    player_2_fleet_coords = params["player_2_fleet_coords"] || random_fleet_layout
    whose_move = 0 # player_1 is 0, player_2 is 1, so starts as player_1's move
    player_1_id = params["player_id"] if params["player_id"]
  end

  def salvo_status(coordinate, player_number)
    status = {}
    player_fleet_status = 1 == player_number ? player_1_fleet_status : player_2_fleet_status
    player_fleet_coords = 1 == player_number ? player_1_fleet_coords : player_2_fleet_coords
    ship_part_index = player_fleet_coords.index(coordinate) 

    if ship_part_index
      # The ship_part_index is used to create a mask used to clear
      # the bit representing the ship_part in the fleet_status.
      ship_part_mask    = 1 << ship_part_index
      player_fleet_status  &= ~ship_part_mask

      ship_mask = get_ship_mask(ship_part_mask)
      ship = SHIP_NAMES[ship_mask]

      ship_is_sunk = SUNK == player_fleet_status & ship_mask
      fleet_sunk   = SUNK == player_fleet_status
      message  = ship_is_sunk ? "You sunk my #{ship}!" : "You hit my #{ship}."
      message += " And you've destroyed my fleet!" if fleet_sunk

      status = {"salvo_report" => "hit", "message" => message, "ship_hit" => ship_hit}
      status["fleet_sunk"] = true if fleet_sunk
    else
      status["salvo_report"] = "miss"
    end
    
    return status
  end

  private

  SAMPLE_LAYOUTS = [
    ["a1",   "b1", "b2",   "c1", "c2", "c3",   "d1", "d2", "d3", "d4",   "e1", "e2", "e3", "e4", "e5" ],
    ["b2",   "b4", "c4",   "d1", "d2", "d3",   "i4", "i5", "i6", "i7",   "e9", "f9", "g9", "h9", "i9" ]
  ]
  # Stub, not very random yet
  def random_fleet_layout
    SAMPLE_LAYOUTS[rand(SAMPLE_LAYOUTS.size)]
  end

  # Get the full ship mask from the partial ship mask
  def get_ship_mask(ship_part_mask)
    SHIP_MASKS.select {|mask| 0 != (mask & ship_part_mask) }.first
  end

  def increment_whose_turn_it_is
    whose_move = (whose_move + 1) % NUMBER_OF_PLAYERS
  end


end
