require 'test_helper'

#  Tests to write:
#  √ game init to defaults
#  √ if game is created with no player IDs, state is waiting for players 1 & 2 to join
#  √ if game is created with just player 1, state is waiting for player 2 to join
#  √ if game is created with just player 2, state is waiting for player 1 to join
#  √ if game is created with both players 1 & 2, state is waiting for player 1 to move
#  √ game join player 2
#    Game model and/or controller Tests that the correct game state message is returned at appropriate times.


class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:game_1)
  end

  test "should get index" do
    get games_url
    assert_response :success
  end

  test "should get new" do
    get new_game_url
    assert_response :success
  end

  test "should provide defaults in new game" do
    get new_game_url
    new_game = response.instance_variable_get("@request").instance_variable_get("@env")["action_controller.instance"].instance_variable_get("@game")
    assert_equal(Game.an_intact_fleet_status, new_game.player_1_fleet_status)
    assert_equal(Game.an_intact_fleet_status, new_game.player_2_fleet_status)
    assert_equal(0, new_game.whose_move)
    assert_equal(0, new_game.move_counter)
  end

  test "should create game" do
    assert_difference('Game.count') do
      post games_url, params: { game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                        player_1_fleet_status: @game.player_1_fleet_status,
                                        player_1_id: @game.player_1_id,
                                        player_2_fleet_coords: @game.player_2_fleet_coords,
                                        player_2_fleet_status: @game.player_2_fleet_status,
                                        player_2_id: @game.player_2_id,
                                        whose_move: Game::PLAYER_1,
                                        move_counter: 0,
                                        title: @game.title + " too"} }
    end
    assert_redirected_to game_path(Game.last)
  end

  test "should create game which is waiting for both players to join" do
    post games_url, params: { game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                      player_1_fleet_status: @game.player_1_fleet_status,
                                      player_1_id: nil,
                                      player_2_fleet_coords: @game.player_2_fleet_coords,
                                      player_2_fleet_status: @game.player_2_fleet_status,
                                      player_2_id: nil,
                                      whose_move: Game::PLAYER_1,
                                      move_counter: 0,
                                      title: "waiting_for_p_2"} }
    assert_equal("Waiting for all players to join", flash[:notice])
  end

  test "should create game which is waiting for player 2 to join" do
    post games_url, params: { game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                      player_1_fleet_status: @game.player_1_fleet_status,
                                      player_1_id: 1,
                                      player_2_fleet_coords: @game.player_2_fleet_coords,
                                      player_2_fleet_status: @game.player_2_fleet_status,
                                      player_2_id: nil,
                                      whose_move: Game::PLAYER_1,
                                      move_counter: 0,
                                      title: "waiting_for_p_2"} }
    assert_equal("Waiting for player 2 to join", flash[:notice])
  end

  test "should create game which is waiting for player 1 to join" do
    post games_url, params: { game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                      player_1_fleet_status: @game.player_1_fleet_status,
                                      player_1_id: nil,
                                      player_2_fleet_coords: @game.player_2_fleet_coords,
                                      player_2_fleet_status: @game.player_2_fleet_status,
                                      player_2_id: 2,
                                      whose_move: Game::PLAYER_1,
                                      move_counter: 0,
                                      title: "waiting_for_p_2"} }
    assert_equal("Waiting for player 1 to join", flash[:notice])
  end

  test "should create game which is waiting for player 1 to move" do
    post games_url, params: { game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                      player_1_fleet_status: @game.player_1_fleet_status,
                                      player_1_id: 1,
                                      player_2_fleet_coords: @game.player_2_fleet_coords,
                                      player_2_fleet_status: @game.player_2_fleet_status,
                                      player_2_id: 2,
                                      whose_move: Game::PLAYER_1,
                                      move_counter: 0,
                                      title: "waiting_for_p_2"} }
    assert_equal("Waiting for player 1 to move", flash[:notice])
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
    patch game_url(@game), params: { game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                             player_1_fleet_status: @game.player_1_fleet_status,
                                             player_1_id: @game.player_1_id,
                                             player_2_fleet_coords: @game.player_2_fleet_coords,
                                             player_2_fleet_status: @game.player_2_fleet_status,
                                             player_2_id: @game.player_2_id,
                                             whose_move: Game::PLAYER_2,
                                             move_counter: 1,
                                             title: @game.title } }
    assert_redirected_to game_path(@game)
  end

  test "should join player 2 to game" do
    @game_waiting_for_p2_join = games(:game_waiting_for_p2_join)
    patch join_game_url(@game_waiting_for_p2_join), params: { game: { player_2_id: 2 } }
    assert_redirected_to game_path(@game_waiting_for_p2_join)
    assert_equal("Waiting for player 1 to move", flash[:notice])
    joined_game = response.instance_variable_get("@request").instance_variable_get("@env")["action_controller.instance"].instance_variable_get("@game")
    assert_equal(2, joined_game.player_2_id )
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete game_url(@game)
    end

    assert_redirected_to games_path
  end
end
