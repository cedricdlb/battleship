require 'test_helper'

class MovesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @move = moves(:one)
  end

  test "should get index" do
    get moves_url
    assert_response :success
  end

  test "should get new" do
    get new_move_url
    assert_response :success
  end

  test "should create move" do
    assert_difference('Move.count') do
      post moves_url, params: { move: { attack_coords: @move.attack_coords, fleet_sunk: @move.fleet_sunk, game_id: @move.game_id, hit: @move.hit, player_id: @move.player_id, ship_part_hit: @move.ship_part_hit, ship_sunk: @move.ship_sunk, turn_number: @move.turn_number } }
    end

    assert_redirected_to move_path(Move.last)
  end

  test "should show move" do
    get move_url(@move)
    assert_response :success
  end

  test "should get edit" do
    get edit_move_url(@move)
    assert_response :success
  end

  test "should update move" do
    patch move_url(@move), params: { move: { attack_coords: @move.attack_coords, fleet_sunk: @move.fleet_sunk, game_id: @move.game_id, hit: @move.hit, player_id: @move.player_id, ship_part_hit: @move.ship_part_hit, ship_sunk: @move.ship_sunk, turn_number: @move.turn_number } }
    assert_redirected_to move_path(@move)
  end

  test "should destroy move" do
    assert_difference('Move.count', -1) do
      delete move_url(@move)
    end

    assert_redirected_to moves_path
  end
end
