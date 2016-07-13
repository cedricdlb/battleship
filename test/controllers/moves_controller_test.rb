require 'test_helper'

class MovesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:game_1)
   #@move = moves(:move_1)
    @move = moves(:move_1_p_1)
  end

  test "should get index" do
    get game_moves_url(@game)
    assert_response :success
  end

  test "should get new" do
    get new_game_move_url(@game)
    assert_response :success
  end

  test "should create move, set player_2 as next to move, and increment turn counter" do
    assert_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move.attack_coords,
                                                    game_id:       @move.game_id,
                                                    player_id:     @move.player_id } }
    end
    completed_move = Move.order(:updated_at).last
    updated_game = Game.order(:updated_at).last

    assert_redirected_to game_move_path(updated_game, completed_move)
    assert_equal(Game::PLAYER_2, updated_game.whose_move)
    assert_equal(1, completed_move.move_number)
  end

 #player_1_fleet_coords: ["a1",   "b1", "b2",   "c1", "c2", "c3",   "d1", "d2", "d3", "d4",   "e1", "e2", "e3", "e4", "e5" ]
 #player_2_fleet_coords: ["b2",   "b4", "c4",   "d1", "d2", "d3",   "i4", "i5", "i6", "i7",   "e9", "f9", "g9", "h9", "i9" ]
  test "should create move and register hit to Submarine" do
    assert_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move.attack_coords,
                                                    game_id:       @move.game_id,
                                                    player_id:     @move.player_id } }
    end
    completed_move = Move.order(:updated_at).last
    updated_game = Game.order(:updated_at).last

    assert_redirected_to game_move_path(updated_game, completed_move)
    assert     completed_move.hit,        "Expected attack_coords #{@move.attack_coords} to hit against fleet coords #{@game.player_2_fleet_coords}"
    assert     completed_move.ship_sunk,  "Expected attack_coords #{@move.attack_coords} to sink one of player_2's ships with fleet coords #{@game.player_2_fleet_coords}"
    assert_not completed_move.fleet_sunk, "Expected attack_coords #{@move.attack_coords} to not sink player_2's fleet"
    assert_equal("Submarine", completed_move.ship_part_hit, "Expected attack_coords #{@move.attack_coords} to sink player_2's submarine")
    assert_equal(1, completed_move.move_number)
  end

  test "should create move and register miss" do
    @move = moves(:move_2_p_1)
    assert_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move.attack_coords,
                                                    game_id:       @move.game_id,
                                                    player_id:     @move.player_id,
                                                    move_number:   @move.move_number } }
    end
    completed_move = Move.order(:updated_at).last
    updated_game = Game.order(:updated_at).last

    assert_redirected_to game_move_path(updated_game, completed_move)
    assert_not completed_move.hit,           "Expected attack_coords #{@move.attack_coords} to miss against fleet coords #{@game.player_2_fleet_coords}"
    assert_not completed_move.ship_sunk,     "Expected attack_coords #{@move.attack_coords} to not sink any of player_2's ships with fleet coords #{@game.player_2_fleet_coords}"
    assert_not completed_move.fleet_sunk,    "Expected attack_coords #{@move.attack_coords} to not sink player_2's fleet"
    assert_nil completed_move.ship_part_hit, "Expected attack_coords #{@move.attack_coords} to not sink any of player_2's ships with fleet coords #{@game.player_2_fleet_coords}" 
    assert_equal(1, completed_move.move_number)
    assert_equal(Game::PLAYER_2, updated_game.whose_move)
    assert_equal(Game.an_intact_fleet_status, updated_game.player_2_fleet_status, "Expected a miss to not damage player 2's fleet")
  end

  test "should not allow players to move twice in a row" do
    ################################
    # Player 1 moves a first time
    assert_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move.attack_coords,
                                                    game_id:       @move.game_id,
                                                    player_id:     @move.player_id } }
    end
    updated_game = Game.order(:updated_at).last
    assert_equal(Game::PLAYER_2, updated_game.whose_move, "player 1 moving a first time should have made it player 2's turn")
    assert_equal(1, Move.order(:updated_at).last.move_number)

    ################################
    # Player 1 tries to move again
    @move_2_p_1 = moves(:move_2_p_1 )
    assert_no_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move_2_p_1.attack_coords,
                                                    game_id:       @move_2_p_1.game_id,
                                                    player_id:     @move_2_p_1.player_id } }
    end
    updated_game = Game.order(:updated_at).last
    assert_response(:locked)
    assert_equal(Game::PLAYER_2, updated_game.whose_move, "player 1 trying to move twice in a row should not have altered whose turn it is")
    assert_equal(1, Move.order(:updated_at).last.move_number)

    ################################
    # Player 2 moves a first time
    @move_1_p_2 = moves(:move_1_p_2)
    assert_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move_1_p_2.attack_coords,
                                                    game_id:       @move_1_p_2.game_id,
                                                    player_id:     @move_1_p_2.player_id } }
    end
    updated_game = Game.order(:updated_at).last
    assert_equal(Game::PLAYER_1, updated_game.whose_move, "player 2 moving a first time should have made it player 1's turn")
    assert_equal(2, Move.order(:updated_at).last.move_number)

    ################################
    # Player 2 tries to move again
    @move_2_p_2 = moves(:move_2_p_2)
    assert_no_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move_2_p_2.attack_coords,
                                                    game_id:       @move_2_p_2.game_id,
                                                    player_id:     @move_2_p_2.player_id } }
    end
    updated_game = Game.order(:updated_at).last
    assert_response(:locked)
    assert_equal(Game::PLAYER_1, updated_game.whose_move, "player 2 trying to move twice in a row should not have altered whose turn it is")
    assert_equal(2, Move.order(:updated_at).last.move_number)
  end

  # player_2_fleet_coords: ["b2",   "b4", "c4",   "d1", "d2", "d3",   "i4", "i5", "i6", "i7",   "e9", "f9", "g9", "h9", "i9" ]
  # @move.attack_coords:    "b2"
  test "should allow player 2 one last shot as her fleet is sunk" do
    @game.player_2_fleet_status = Game::SUBMARINE_MASK # All ships sunk except the submarine at b2
    @game.move_counter = 28
    @game.save
    assert_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move.attack_coords,
                                                    game_id:       @move.game_id,
                                                    player_id:     @move.player_id } }
    end
    completed_move = Move.order(:updated_at).last
    updated_game = Game.order(:updated_at).last
    assert_redirected_to game_move_path(updated_game, completed_move)
    assert_equal(29, completed_move.move_number)

    # First verify the ship and fleet are sunk
    assert     completed_move.hit,           "Expected attack_coords #{@move.attack_coords} to hit against fleet coords #{@game.player_2_fleet_coords}"
    assert     completed_move.ship_sunk,     "Expected attack_coords #{@move.attack_coords} to sink player_2's Submarine with fleet coords #{@game.player_2_fleet_coords}"
    assert     completed_move.fleet_sunk,    "Expected attack_coords #{@move.attack_coords} to sink player_2's fleet"
    assert_equal("Submarine", completed_move.ship_part_hit, "Expected attack_coords #{@move.attack_coords} to sink player_2's Submarine with fleet coords #{@game.player_2_fleet_coords}")
    assert_equal(Game::SUNK, updated_game.player_2_fleet_status, "Expected this hit to sink player 2's fleet")
    assert_equal(Game::PLAYER_2, updated_game.whose_move)
    assert_equal(Game::STATE_WAITING_PLAYER_2_TO_MOVE, updated_game.game_state)

    # Now verify player_2 can have a go
    @move_1_p_2 = moves(:move_1_p_2)
    assert_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move_1_p_2.attack_coords,
                                                    game_id:       @move_1_p_2.game_id,
                                                    player_id:     @move_1_p_2.player_id } }
    end
    completed_move = Move.order(:updated_at).last
    updated_game = Game.order(:updated_at).last
    assert_equal(Game::STATE_GAME_OVER_PLAYER_1_WON, updated_game.game_state)
    assert_equal(30, completed_move.move_number)

    # Finally, verify player_2 can not go a second time after their last shot
    @move_2_p_2 = moves(:move_2_p_2)
    assert_no_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move_2_p_2.attack_coords,
                                                    game_id:       @move_2_p_2.game_id,
                                                    player_id:     @move_2_p_2.player_id } }
    end
    completed_move = Move.order(:updated_at).last
    updated_game = Game.order(:updated_at).last
    assert_equal(Game::STATE_GAME_OVER_PLAYER_1_WON, updated_game.game_state)
    assert_equal(30, completed_move.move_number)
  end

  # player_1_fleet_coords: ["a1",   "b1", "b2",   "c1", "c2", "c3",   "d1", "d2", "d3", "d4",   "e1", "e2", "e3", "e4", "e5" ]
  # @move.attack_coords:    "a1"
  test "should not allow player 1 to go again once his fleet is sunk" do
    @game.player_1_fleet_status = Game::SUBMARINE_MASK # All ships sunk except the submarine at a1
    @game.whose_move = Game::PLAYER_2
    @game.move_counter = 29
    @game.save
    @move = moves(:move_1_p_2)
    assert_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move.attack_coords,
                                                    game_id:       @move.game_id,
                                                    player_id:     @move.player_id } }
    end
    completed_move = Move.order(:updated_at).last
    updated_game = Game.order(:updated_at).last
    assert_redirected_to game_move_path(updated_game, completed_move)

    # First verify the ship and fleet are sunk
    assert completed_move.hit,        "Expected attack_coords #{@move.attack_coords} to hit against fleet coords #{@game.player_1_fleet_coords}"
    assert completed_move.ship_sunk,  "Expected attack_coords #{@move.attack_coords} to sink player_1's Submarine with fleet coords #{@game.player_1_fleet_coords}"
    assert completed_move.fleet_sunk, "Expected attack_coords #{@move.attack_coords} to sink player_1's fleet"
    assert_equal("Submarine", completed_move.ship_part_hit, "Expected attack_coords #{@move.attack_coords} to sink player_1's Submarine with fleet coords #{@game.player_1_fleet_coords}")
    assert_equal(Game::SUNK, updated_game.player_1_fleet_status, "Expected this hit to sink player 1's fleet")
    assert_equal(Game::STATE_GAME_OVER_PLAYER_2_WON, updated_game.game_state)
    assert_equal(30, completed_move.move_number)

    # Now verify player_1 can not move
    @move_2_p_1 = moves(:move_2_p_1)
    assert_no_difference('Move.count') do
      post game_moves_url(@game), params: { move: { attack_coords: @move_2_p_1.attack_coords,
                                                    game_id:       @move_2_p_1.game_id,
                                                    player_id:     @move_2_p_1.player_id } }
    end
    completed_move = Move.order(:updated_at).last
    updated_game = Game.order(:updated_at).last
    assert_response(:locked)
    assert_equal(Game::STATE_GAME_OVER_PLAYER_2_WON, updated_game.game_state, "Expected Game status to be STATE_GAME_OVER_PLAYER_2_WON (#{Game::STATE_GAME_OVER_PLAYER_2_WON}), but it was #{updated_game.game_state}")
    assert_equal(30, completed_move.move_number)
  end

  # player_1_fleet_coords: ["a1",   "b1", "b2",   "c1", "c2", "c3",   "d1", "d2", "d3", "d4",   "e1", "e2", "e3", "e4", "e5" ]
  # player_2_fleet_coords: ["b2",   "b4", "c4",   "d1", "d2", "d3",   "i4", "i5", "i6", "i7",   "e9", "f9", "g9", "h9", "i9" ]
  # @move.attack_coords:    "a1"
  # @move.attack_coords:    "b2"
  test "should lead to tie game state after both fleets are sunk" do
    @game.player_1_fleet_status = Game::SUBMARINE_MASK # All ships sunk except the submarine at a1
    @game.player_2_fleet_status = Game::SUBMARINE_MASK # All ships sunk except the submarine at b2
    @game.move_counter = 28
    @game.save
    post game_moves_url(@game), params: { move: { attack_coords: @move.attack_coords,
                                                  game_id:       @move.game_id,
                                                  player_id:     @move.player_id } }
    @move_1_p_2 = moves(:move_1_p_2)
    post game_moves_url(@game), params: { move: { attack_coords: @move_1_p_2.attack_coords,
                                                  game_id:       @move_1_p_2.game_id,
                                                  player_id:     @move_1_p_2.player_id } }
    updated_game = Game.order(:updated_at).last
    assert_equal(Game::STATE_GAME_OVER_TIED_GAME, updated_game.game_state, "Expected Game status to be STATE_GAME_OVER_TIED_GAME (#{Game::STATE_GAME_OVER_TIED_GAME}), but it was #{updated_game.game_state}")
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
    patch game_move_url(@game, @move), params: { move: { attack_coords: @move.attack_coords,
                                                         fleet_sunk:    @move.fleet_sunk,
                                                         game_id:       @move.game_id,
                                                         hit:           @move.hit,
                                                         player_id:     @move.player_id,
                                                         ship_part_hit: @move.ship_part_hit,
                                                         ship_sunk:     @move.ship_sunk,
                                                         move_number:   @move.move_number } }
    assert_redirected_to game_move_path(@game, @move)
  end

  test "should destroy move" do
    assert_difference('Move.count', -1) do
      delete game_move_url(@game, @move)
    end

    assert_redirected_to game_moves_path(@game)
  end
end
