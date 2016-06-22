json.array!(@moves) do |move|
  json.extract! move, :id, :game_id, :player_id, :turn_number, :attack_coords, :hit, :ship_part_hit, :ship_sunk, :fleet_sunk
 #json.url move_url(move, format: :json)
  json.url game_move_url(move, format: :json)
end
