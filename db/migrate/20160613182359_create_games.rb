class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.string  :title
      t.integer :player_1_id
      t.integer :player_2_id
      t.integer :whose_move
      t.integer :move_counter
      t.integer :player_1_fleet_status
      t.integer :player_2_fleet_status
      t.text    :player_1_fleet_coords
      t.text    :player_2_fleet_coords
      t.timestamps
    end
  end
end
