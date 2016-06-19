class CreateMoves < ActiveRecord::Migration[5.0]
  def change
    create_table :moves do |t|
      t.integer :game_id
      t.integer :player_id
      t.integer :turn_number
      t.text    :attack_coords
      t.boolean :hit
      t.string  :ship_part_hit
      t.string  :ship_sunk
      t.boolean :fleet_sunk
    end
  end
end
