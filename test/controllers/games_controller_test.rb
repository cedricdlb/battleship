require 'test_helper'

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

  # HTML request
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
    
  # API Request (JSON)
  test "should create game as API" do
    assert_difference('Game.count') do
      post games_url, params: { format: :json,
                                game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                        player_1_fleet_status: @game.player_1_fleet_status,
                                        player_1_id: @game.player_1_id,
                                        player_2_fleet_coords: @game.player_2_fleet_coords,
                                        player_2_fleet_status: @game.player_2_fleet_status,
                                        player_2_id: @game.player_2_id,
                                        whose_move: Game::PLAYER_1,
                                        move_counter: 0,
                                        title: @game.title + " too"} }
    end
    json = JSON.parse(response.body)
    assert_equal(Game::STATE_WAITING_PLAYER_1_TO_MOVE, json["game_state"],   "Unexpected value for json['game_state'] (Expected STATE_WAITING_PLAYER_1_TO_MOVE)")
    assert_equal("Waiting for player 1 to move", json["game_state_message"])
    assert_equal(@game.player_1_fleet_coords, json["player_1_fleet_coords"], "Unexpected value for json['player_1_fleet_coords']")
    assert_equal(@game.player_2_fleet_coords, json["player_2_fleet_coords"], "Unexpected value for json['player_2_fleet_coords']")
    assert_equal(@game.player_1_fleet_status, json["player_1_fleet_status"], "Unexpected value for json['player_1_fleet_status']")
    assert_equal(@game.player_2_fleet_status, json["player_2_fleet_status"], "Unexpected value for json['player_2_fleet_status']")
    assert_equal(@game.player_1_id,           json["player_1_id"],           "Unexpected value for json['player_1_id']")
    assert_equal(@game.player_2_id,           json["player_2_id"],           "Unexpected value for json['player_2_id']")
    assert_equal(Game::PLAYER_1,              json["whose_move"],            "Unexpected value for json['whose_move'] (Expected Game::PLAYER_1)")
    assert_equal(0,                           json["move_counter"],          "Unexpected value for json['move_counter']")
  end

  # HTML request
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

  # API request (JSON)
  test "should create game which is waiting for both players to join as API" do
    post games_url, params: { format: :json,
                              game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                      player_1_fleet_status: @game.player_1_fleet_status,
                                      player_1_id: nil,
                                      player_2_fleet_coords: @game.player_2_fleet_coords,
                                      player_2_fleet_status: @game.player_2_fleet_status,
                                      player_2_id: nil,
                                      whose_move: Game::PLAYER_1,
                                      move_counter: 0,
                                      title: "waiting_for_p_2"} }
    json = JSON.parse(response.body)
    assert_equal(Game::STATE_WAITING_ALL_PLAYERS_TO_JOIN, json["game_state"], "Unexpected value for json['game_state'] (Expected STATE_WAITING_ALL_PLAYERS_TO_JOIN)")
    assert_equal("Waiting for all players to join", json["game_state_message"])
  end

  # HTML request
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

  # API request
  test "should create game which is waiting for player 2 to join as API" do
    post games_url, params: { format: :json,
                              game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                      player_1_fleet_status: @game.player_1_fleet_status,
                                      player_1_id: 1,
                                      player_2_fleet_coords: @game.player_2_fleet_coords,
                                      player_2_fleet_status: @game.player_2_fleet_status,
                                      player_2_id: nil,
                                      whose_move: Game::PLAYER_1,
                                      move_counter: 0,
                                      title: "waiting_for_p_2"} }
    json = JSON.parse(response.body)
    assert_equal(Game::STATE_WAITING_PLAYER_2_TO_JOIN, json["game_state"], "Unexpected value for json['game_state'] (Expected STATE_WAITING_PLAYER_2_TO_JOIN)")
    assert_equal("Waiting for player 2 to join", json["game_state_message"])
  end

  # HTML request
  test "should create game which is waiting for player 1 to join" do
    post games_url, params: { game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                      player_1_fleet_status: @game.player_1_fleet_status,
                                      player_1_id: nil,
                                      player_2_fleet_coords: @game.player_2_fleet_coords,
                                      player_2_fleet_status: @game.player_2_fleet_status,
                                      player_2_id: 2,
                                      whose_move: Game::PLAYER_1,
                                      move_counter: 0,
                                      title: "waiting_for_p_1"} }
    assert_equal("Waiting for player 1 to join", flash[:notice])
  end

  # API request
  test "should create game which is waiting for player 1 to join as API" do
    post games_url, params: { format: :json,
                              game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                      player_1_fleet_status: @game.player_1_fleet_status,
                                      player_1_id: nil,
                                      player_2_fleet_coords: @game.player_2_fleet_coords,
                                      player_2_fleet_status: @game.player_2_fleet_status,
                                      player_2_id: 2,
                                      whose_move: Game::PLAYER_1,
                                      move_counter: 0,
                                      title: "waiting_for_p_1"} }
    json = JSON.parse(response.body)
    assert_equal(Game::STATE_WAITING_PLAYER_1_TO_JOIN, json["game_state"], "Unexpected value for json['game_state'] (Expected STATE_WAITING_PLAYER_1_TO_JOIN)")
    assert_equal("Waiting for player 1 to join", json["game_state_message"])
  end

  # HTML request
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

  # API request
  test "should create game which is waiting for player 1 to move as API" do
    post games_url, params: { format: :json,
                              game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                                      player_1_fleet_status: @game.player_1_fleet_status,
                                      player_1_id: 1,
                                      player_2_fleet_coords: @game.player_2_fleet_coords,
                                      player_2_fleet_status: @game.player_2_fleet_status,
                                      player_2_id: 2,
                                      whose_move: Game::PLAYER_1,
                                      move_counter: 0,
                                      title: "waiting_for_p_2"} }
    json = JSON.parse(response.body)
    assert_equal(Game::STATE_WAITING_PLAYER_1_TO_MOVE, json["game_state"],   "Unexpected value for json['game_state'] (Expected STATE_WAITING_PLAYER_1_TO_MOVE)")
    assert_equal("Waiting for player 1 to move", json["game_state_message"])
  end

  # HTML request
  test "should show game" do
    get game_url(@game)
    assert_response :success
  end

  # API request
  test "should show game as API" do
    get game_url(@game), params: { format: :json }
    json = JSON.parse(response.body)
    assert_equal(Game::STATE_WAITING_PLAYER_1_TO_MOVE, json["game_state"],   "Unexpected value for json['game_state'] (Expected STATE_WAITING_PLAYER_1_TO_MOVE)")
    assert_equal("Waiting for player 1 to move", json["game_state_message"])
    assert_equal(@game.player_1_fleet_coords, json["player_1_fleet_coords"], "Unexpected value for json['player_1_fleet_coords']")
    assert_equal(@game.player_2_fleet_coords, json["player_2_fleet_coords"], "Unexpected value for json['player_2_fleet_coords']")
    assert_equal(@game.player_1_fleet_status, json["player_1_fleet_status"], "Unexpected value for json['player_1_fleet_status']")
    assert_equal(@game.player_2_fleet_status, json["player_2_fleet_status"], "Unexpected value for json['player_2_fleet_status']")
    assert_equal(@game.player_1_id,           json["player_1_id"],           "Unexpected value for json['player_1_id']")
    assert_equal(@game.player_2_id,           json["player_2_id"],           "Unexpected value for json['player_2_id']")
    assert_equal(Game::PLAYER_1,              json["whose_move"],            "Unexpected value for json['whose_move'] (Expected Game::PLAYER_1)")
    assert_equal(0,                           json["move_counter"],          "Unexpected value for json['move_counter']")
  end

  # HTML request
  test "should get edit" do
    get edit_game_url(@game)
    assert_response :success
  end

  # HTML request
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

  # API request
  test "should update game as API" do
    @game_2 = games(:game_2)
    patch game_url(@game), params: { format: :json,
                                     game: { player_1_fleet_coords: @game_2.player_1_fleet_coords,
                                             player_1_fleet_status: @game_2.player_1_fleet_status,
                                             player_1_id: @game_2.player_1_id,
                                             player_2_fleet_coords: @game_2.player_2_fleet_coords,
                                             player_2_fleet_status: @game_2.player_2_fleet_status,
                                             player_2_id: @game_2.player_2_id,
                                             whose_move: Game::PLAYER_2,
                                             move_counter: 10,
                                             title: @game.title + " renamed"} }
    json = JSON.parse(response.body)
    assert_equal(Game::STATE_WAITING_PLAYER_2_TO_MOVE, json["game_state"],   "Unexpected value for json['game_state'] (Expected STATE_WAITING_PLAYER_2_TO_MOVE)")
    assert_equal("Waiting for player 2 to move", json["game_state_message"])
    assert_equal(@game_2.player_1_fleet_coords, json["player_1_fleet_coords"], "Unexpected value for json['player_1_fleet_coords']")
    assert_equal(@game_2.player_2_fleet_coords, json["player_2_fleet_coords"], "Unexpected value for json['player_2_fleet_coords']")
    assert_equal(@game_2.player_1_fleet_status, json["player_1_fleet_status"], "Unexpected value for json['player_1_fleet_status']")
    assert_equal(@game_2.player_2_fleet_status, json["player_2_fleet_status"], "Unexpected value for json['player_2_fleet_status']")
    assert_equal(@game_2.player_1_id,           json["player_1_id"],           "Unexpected value for json['player_1_id']")
    assert_equal(@game_2.player_2_id,           json["player_2_id"],           "Unexpected value for json['player_2_id']")
    assert_equal(Game::PLAYER_2,                json["whose_move"],            "Unexpected value for json['whose_move'] (Expected Game::PLAYER_1)")
    assert_equal(10,                             json["move_counter"],          "Unexpected value for json['move_counter']")
  end

  # HTML request
  test "should join player 2 to game" do
    @game_waiting_for_p2_join = games(:game_waiting_for_p2_join)
    patch join_game_url(@game_waiting_for_p2_join), params: { game: { player_2_id: 2 } }
    assert_redirected_to game_path(@game_waiting_for_p2_join)
    assert_equal("Waiting for player 1 to move", flash[:notice])
    joined_game = response.instance_variable_get("@request").instance_variable_get("@env")["action_controller.instance"].instance_variable_get("@game")
    assert_equal(2, joined_game.player_2_id )
  end

  # API request
  test "should join player 2 to game as API" do
    @game = games(:game_waiting_for_p2_join)
    assert_equal(nil,                            @game.player_2_id,             "@game.player_2_id should be nil before p2 joins")
    patch join_game_url(@game), params: { format: :json, game: { player_2_id: 2 } }

   #assert_redirected_to game_path(@game_waiting_for_p2_join)
   #assert_equal("Waiting for player 1 to move", flash[:notice])
   #joined_game = response.instance_variable_get("@request").instance_variable_get("@env")["action_controller.instance"].instance_variable_get("@game")
   #assert_equal(2, joined_game.player_2_id )

    json = JSON.parse(response.body)
#   assert_equal("", json)
    assert_equal(Game::STATE_WAITING_PLAYER_1_TO_MOVE, json["game_state"],   "Unexpected value for json['game_state'] (Expected STATE_WAITING_PLAYER_1_TO_MOVE)")
    assert_equal("Waiting for player 1 to move", json["game_state_message"])
    assert_equal(@game.player_1_id,              json["player_1_id"],           "Unexpected value for json['player_1_id']")
    assert_equal(2,                              json["player_2_id"],           "json['player_2_id'] should be 2 after p2 joins.")
    assert_equal(Game::PLAYER_1,                 json["whose_move"],            "Unexpected value for json['whose_move'] (Expected Game::PLAYER_1)")
  end

  class ContextGameStatus < GamesControllerTest 
    setup do
      @parameters = { game: { player_1_fleet_coords: @game.player_1_fleet_coords,
                              player_1_fleet_status: @game.player_1_fleet_status,
                              player_2_fleet_coords: @game.player_2_fleet_coords,
                              player_2_fleet_status: @game.player_2_fleet_status,
                              whose_move:            Game::PLAYER_1,
                              move_counter:          0,
                              title:                 "Testing GameController#status" }}
    end

    def create_and_return_game(parameters)
      post games_url, params: parameters
      return Game.order(:updated_at).last
    end

    def get_json_game_status(game)
      get status_game_url(game), params: {format: :json}
      return JSON.parse(response.body)
    end

    def create_game_and_get_json_status(parameters)
      created_game = create_and_return_game(parameters)
      get_json_game_status(created_game)
    end
    
    # API Request (JSON)
    test "should return game status waiting for both players" do
      json = create_game_and_get_json_status(@parameters)
      assert_equal(Game::STATE_WAITING_ALL_PLAYERS_TO_JOIN, json["game_state"],
                   "Expected Game state to be STATE_WAITING_ALL_PLAYERS_TO_JOIN (#{Game::STATE_WAITING_ALL_PLAYERS_TO_JOIN}), but it was #{json["game_state"]}")
      assert_equal("Waiting for all players to join", json["game_state_message"])
    end
  
    # API Request (JSON)
    test "should return game status waiting for player 1" do
      @parameters[:game][:player_2_id] = @game.player_2_id
      json = create_game_and_get_json_status(@parameters)
      assert_equal(Game::STATE_WAITING_PLAYER_1_TO_JOIN, json["game_state"],
                   "Expected Game state to be STATE_WAITING_PLAYER_1_TO_JOIN (#{Game::STATE_WAITING_PLAYER_1_TO_JOIN}), but it was #{json["game_state"]}")
      assert_equal("Waiting for player 1 to join", json["game_state_message"])
    end
  
    # API Request (JSON)
    test "should return game status waiting for player 2" do
      @parameters[:game][:player_1_id] = @game.player_1_id
      json = create_game_and_get_json_status(@parameters)
      assert_equal(Game::STATE_WAITING_PLAYER_2_TO_JOIN, json["game_state"],
                   "Expected Game state to be STATE_WAITING_PLAYER_2_TO_JOIN (#{Game::STATE_WAITING_PLAYER_2_TO_JOIN}), but it was #{json["game_state"]}")
      assert_equal("Waiting for player 2 to join", json["game_state_message"])
    end
  
    # API Request (JSON)
    test "should return game status waiting for player 1 to move when all players have joined" do
      @parameters[:game][:player_1_id] = @game.player_1_id
      @parameters[:game][:player_2_id] = @game.player_2_id
      json = create_game_and_get_json_status(@parameters)
      assert_equal(Game::STATE_WAITING_PLAYER_1_TO_MOVE, json["game_state"],
                   "Expected Game state to be STATE_WAITING_PLAYER_1_TO_MOVE (#{Game::STATE_WAITING_PLAYER_1_TO_MOVE}), but it was #{json["game_state"]}")
      assert_equal("Waiting for player 1 to move", json["game_state_message"])
    end
  
    # API Request (JSON)
    test "should return game status waiting for player 2 to move and the results of player 1's last move" do
      @parameters[:game][:player_1_id] = @game.player_1_id
      @parameters[:game][:player_2_id] = @game.player_2_id
      created_game = create_and_return_game(@parameters)
      @move = moves(:move_1_p_1)
      @move.game_id = created_game.id
      post game_moves_url(created_game), params: { move: { attack_coords: @move.attack_coords,
                                                           game_id:       @move.game_id,
                                                           player_id:     @move.player_id } }
      json = get_json_game_status(created_game)
      assert_equal(Game::STATE_WAITING_PLAYER_2_TO_MOVE, json["game_state"],
                   "Expected Game state to be STATE_WAITING_PLAYER_2_TO_MOVE (#{Game::STATE_WAITING_PLAYER_2_TO_MOVE}), but it was #{json["game_state"]}")
      assert_equal("Waiting for player 2 to move", json["game_state_message"])
      assert_equal(@move.game_id,       json["last_move"]["game_id"])
      assert_equal(@move.player_id,     json["last_move"]["player_id"])
      assert_equal(@move.attack_coords, json["last_move"]["attack_coords"])
      assert_equal("Submarine",         json["last_move"]["ship_part_hit"])
      assert                            json["last_move"]["hit"]
      assert                            json["last_move"]["ship_sunk"]
      assert_not                        json["last_move"]["fleet_sunk"]
    end
  
    # API Request (JSON)
    test "should return game status waiting for player 1 to move and the results of player 2's last move" do
      @parameters[:game][:player_2_id] = @game.player_2_id
      @parameters[:game][:player_1_id] = @game.player_1_id
      created_game = create_and_return_game(@parameters)
      @move_p1 = moves(:move_1_p_1)
      @move_p2 = moves(:move_2_p_2)
      @move_p1.game_id = created_game.id
      @move_p2.game_id = created_game.id
      post game_moves_url(created_game), params: { move: { attack_coords: @move_p1.attack_coords,
                                                           game_id:       @move_p1.game_id,
                                                           player_id:     @move_p1.player_id } }
      post game_moves_url(created_game), params: { move: { attack_coords: @move_p2.attack_coords,
                                                           game_id:       @move_p2.game_id,
                                                           player_id:     @move_p2.player_id } }
      json = get_json_game_status(created_game)
      assert_equal(Game::STATE_WAITING_PLAYER_1_TO_MOVE, json["game_state"],
                   "Expected Game state to be STATE_WAITING_PLAYER_1_TO_MOVE (#{Game::STATE_WAITING_PLAYER_1_TO_MOVE}), but it was #{json["game_state"]}")
      assert_equal("Waiting for player 1 to move", json["game_state_message"])
      assert_equal(@move_p2.game_id,       json["last_move"]["game_id"])
      assert_equal(@move_p2.player_id,     json["last_move"]["player_id"])
      assert_equal(@move_p2.attack_coords, json["last_move"]["attack_coords"])
      assert_equal(nil,                    json["last_move"]["ship_part_hit"])
      assert_not                           json["last_move"]["hit"]
      assert_not                           json["last_move"]["ship_sunk"]
      assert_not                           json["last_move"]["fleet_sunk"]
    end

    def setup_nearly_tied_game
       @parameters[:game][:player_1_id] = @game.player_1_id
       @parameters[:game][:player_2_id] = @game.player_2_id
       @parameters[:game][:player_1_fleet_status] = Game::SUBMARINE_MASK # all sunk except sub
       @parameters[:game][:player_2_fleet_status] = Game::SUBMARINE_MASK # all sunk except sub
       @created_game = create_and_return_game(@parameters)
    end

    # player_2_fleet_coords:  ["B2",   "B4", "C4",   "D1", "D2", "D3",   "I4", "I5", "I6", "I7",   "E9", "F9", "G9", "H9", "I9" ]
    #move_1_p_1.attack_coords: "B2"
    def setup_p1_sinks_p2_fleet
       setup_nearly_tied_game
       @move_p1 = moves(:move_1_p_1)
       @move_p1.game_id = @created_game.id
       post game_moves_url(@created_game), params: { move: { attack_coords: @move_p1.attack_coords,
                                                             game_id:       @move_p1.game_id,
                                                             player_id:     @move_p1.player_id } }
    end

    # API Request (JSON)
    test "should return game status waiting for player 2 to move and the results of player 1's last move which sunk p2's fleet" do
      setup_p1_sinks_p2_fleet
      json = get_json_game_status(@created_game)
      assert_equal(Game::STATE_WAITING_PLAYER_2_TO_MOVE, json["game_state"],
                   "Expected Game state to be STATE_WAITING_PLAYER_2_TO_MOVE (#{Game::STATE_WAITING_PLAYER_2_TO_MOVE}), but it was #{json["game_state"]}")
      assert_equal("Waiting for player 2 to move", json["game_state_message"])
      assert_equal(@move_p1.game_id,       json["last_move"]["game_id"])
      assert_equal(@move_p1.player_id,     json["last_move"]["player_id"])
      assert_equal(@move_p1.attack_coords, json["last_move"]["attack_coords"])
      assert_equal("Submarine",            json["last_move"]["ship_part_hit"])
      assert                               json["last_move"]["hit"]
      assert                               json["last_move"]["ship_sunk"]
      assert                               json["last_move"]["fleet_sunk"]
    end
  
    # API Request (JSON)
    test "should return game status player 1 won and the results of player 2's last move (a miss)" do
      setup_p1_sinks_p2_fleet
      @move_p2 = moves(:move_2_p_2) # Attack coords: B3 (misses)
      @move_p2.game_id = @created_game.id
      post game_moves_url(@created_game), params: { move: { attack_coords: @move_p2.attack_coords,
                                                            game_id:       @move_p2.game_id,
                                                            player_id:     @move_p2.player_id } }
      json = get_json_game_status(@created_game)
      assert_equal(Game::STATE_GAME_OVER_PLAYER_1_WON, json["game_state"],
                   "Expected Game state to be STATE_GAME_OVER_PLAYER_1_WON (#{Game::STATE_GAME_OVER_PLAYER_1_WON}), but it was #{json["game_state"]}")
      assert_equal("Game Over: player 1 won", json["game_state_message"])
      assert_equal(@move_p2.game_id,       json["last_move"]["game_id"])
      assert_equal(@move_p2.player_id,     json["last_move"]["player_id"])
      assert_equal(@move_p2.attack_coords, json["last_move"]["attack_coords"])
      assert_equal(nil,                    json["last_move"]["ship_part_hit"])
      assert_not                           json["last_move"]["hit"]
      assert_not                           json["last_move"]["ship_sunk"]
      assert_not                           json["last_move"]["fleet_sunk"]
    end
  
    # API Request (JSON)
    test "should return game status tied game and the results of player 2's last move (a hit)" do
      setup_p1_sinks_p2_fleet
      @move_p2 = moves(:move_1_p_2) # Attack coords: A1 (hits)
      @move_p2.game_id = @created_game.id
      post game_moves_url(@created_game), params: { move: { attack_coords: @move_p2.attack_coords,
                                                            game_id:       @move_p2.game_id,
                                                            player_id:     @move_p2.player_id } }
      json = get_json_game_status(@created_game)
      assert_equal(Game::STATE_GAME_OVER_TIED_GAME, json["game_state"],
                   "Expected Game state to be STATE_GAME_OVER_TIED_GAME (#{Game::STATE_GAME_OVER_TIED_GAME}), but it was #{json["game_state"]}")
      assert_equal("Game Over: tied game", json["game_state_message"])
      assert_equal(@move_p2.game_id,       json["last_move"]["game_id"])
      assert_equal(@move_p2.player_id,     json["last_move"]["player_id"])
      assert_equal(@move_p2.attack_coords, json["last_move"]["attack_coords"])
      assert_equal("Submarine",            json["last_move"]["ship_part_hit"])
      assert                               json["last_move"]["hit"]
      assert                               json["last_move"]["ship_sunk"]
      assert                               json["last_move"]["fleet_sunk"]
    end
  
    # API Request (JSON)
    test "should return game status player 2 won and the results of player 2's last move (a hit)" do
      setup_nearly_tied_game
      @created_game.whose_move = Game::PLAYER_2
      @created_game.save!
      @move_p2 = moves(:move_1_p_2) # Attack coords: A1 (hits)
      @move_p2.game_id = @created_game.id
      post game_moves_url(@created_game), params: { move: { attack_coords: @move_p2.attack_coords,
                                                            game_id:       @move_p2.game_id,
                                                            player_id:     @move_p2.player_id } }
      json = get_json_game_status(@created_game)
      assert_equal(Game::STATE_GAME_OVER_PLAYER_2_WON, json["game_state"], "Expected json['game_state'] to be STATE_GAME_OVER_PLAYER_2_WON")
      assert_equal("Game Over: player 2 won", json["game_state_message"])
      assert_equal(@move_p2.game_id,       json["last_move"]["game_id"])
      assert_equal(@move_p2.player_id,     json["last_move"]["player_id"])
      assert_equal(@move_p2.attack_coords, json["last_move"]["attack_coords"])
      assert_equal("Submarine",            json["last_move"]["ship_part_hit"])
      assert                               json["last_move"]["hit"]
      assert                               json["last_move"]["ship_sunk"]
      assert                               json["last_move"]["fleet_sunk"]
    end
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete game_url(@game)
    end
    assert_redirected_to games_path
  end
end
