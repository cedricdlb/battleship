json.array!(@games) do |game|
  json.extract! game, :id, :title, :player_1_id, :player_2_id, :whose_move, :move_counter, :player_1_fleet_status, :player_2_fleet_status, :player_1_fleet_coords, :player_2_fleet_coords, :game_state, :game_state_message
  json.url game_url(game, format: :json)
end
