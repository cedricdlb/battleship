require 'test_helper'

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:one)
  end

  test "should get index" do
    get games_url
    assert_response :success
  end

  test "should get new" do
    get new_game_url
    assert_response :success
  end

  test "should create game" do
    assert_difference('Game.count') do
      post games_url, params: { game: { player_1_fleet_coords: @game.player_1_fleet_coords, player_1_fleet_status: @game.player_1_fleet_status, player_1_id: @game.player_1_id, player_2_fleet_coords: @game.player_2_fleet_coords, player_2_fleet_status: @game.player_2_fleet_status, player_2_id: @game.player_2_id, title: @game.title } }
    end

    assert_redirected_to game_path(Game.last)
  end

  test "should show game" do
    get game_url(@game)
    assert_response :success
  end

  test "should get edit" do
    get edit_game_url(@game)
    assert_response :success
  end

  test "should update game" do
    patch game_url(@game), params: { game: { player_1_fleet_coords: @game.player_1_fleet_coords, player_1_fleet_status: @game.player_1_fleet_status, player_1_id: @game.player_1_id, player_2_fleet_coords: @game.player_2_fleet_coords, player_2_fleet_status: @game.player_2_fleet_status, player_2_id: @game.player_2_id, title: @game.title } }
    assert_redirected_to game_path(@game)
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete game_url(@game)
    end

    assert_redirected_to games_path
  end
end
