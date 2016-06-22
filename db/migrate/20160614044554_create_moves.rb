class CreateMoves < ActiveRecord::Migration[5.0]
  def change
    create_table :moves do |t|
      t.integer :game_id
      t.integer :player_id
      t.integer :turn_number
      t.string  :attack_coords
      t.string  :ship_part_hit
      t.boolean :hit
      t.boolean :ship_sunk
      t.boolean :fleet_sunk
      t.text    :message
    end
  end
end
