require 'test_helper'

class MovesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:game_1)
    @move = moves(:move_1)
  end

  test "should get index" do
    get game_moves_url(@game)
    assert_response :success
  end

  test "should get new" do
    get new_game_move_url(@game)
    assert_response :success
  end

  test "should create move" do
    assert_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move.attack_coords, fleet_sunk: @move.fleet_sunk, game_id: @move.game_id, hit: @move.hit, player_id: @move.player_id, ship_part_hit: @move.ship_part_hit, ship_sunk: @move.ship_sunk, turn_number: @move.turn_number } }
    end

    assert_redirected_to game_move_path(@game, Move.last)
  end

  test "should show move" do
    get game_move_url(@game, @move)
    assert_response :success
  end

  test "should get edit" do
    get edit_game_move_url(@game, @move)
    assert_response :success
  end

  test "should update move" do
    patch game_move_url(@game, @move), params: { move: { attack_coords: @move.attack_coords, fleet_sunk: @move.fleet_sunk, game_id: @move.game_id, hit: @move.hit, player_id: @move.player_id, ship_part_hit: @move.ship_part_hit, ship_sunk: @move.ship_sunk, turn_number: @move.turn_number } }
    assert_redirected_to game_move_path(@game, @move)
  end

  test "should destroy move" do
    assert_difference('Move.count', -1) do
      delete game_move_url(@game, @move)
    end

    assert_redirected_to game_moves_path(@game)
  end
end
