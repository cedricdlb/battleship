require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  setup do
    @game = games(:game_1)
  end

  test "should generate random fleet coordinates" do
    sets_of_fleet_coords = []
    10.times { sets_of_fleet_coords << Game.random_fleet_layout }
    number_of_unique_sets = sets_of_fleet_coords.uniq.count
    # no internet, can't look up assertion for val w/in range
    assert 8 <= number_of_unique_sets, "Expected at least 8 (80%) of random layouts to be unique, but there were only #{number_of_unique_sets} (#{number_of_unique_sets*100/10}%)"
  end

end
