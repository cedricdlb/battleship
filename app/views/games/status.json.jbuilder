json.extract! @game, :id, :title, :player_1_id, :player_2_id, :whose_move, :move_counter, :game_state, :game_state_message, :created_at, :updated_at
if @last_move
  json.last_move do
     json.extract! @last_move, :id, :game_id, :player_id, :move_number, :attack_coords, :hit, :ship_part_hit, :ship_sunk, :fleet_sunk, :created_at, :updated_at
  end
end
