json.array!(@moves) do |move|
  json.extract! move, :id, :game_id, :player_id, :move_number, :attack_coords, :hit, :ship_part_hit, :ship_sunk, :fleet_sunk, :message
  json.url game_move_url(move, format: :json)
end
