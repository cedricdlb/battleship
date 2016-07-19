class Api::V1::MovesController < Api::V1::BaseController
  before_action :set_game #, only: [:show, :new, :create, :edit, :update, :join, :destroy]
 #before_action :set_move, only: [:show, :destroy]
  before_action :set_move, only: :show

  # GET api/v1/games/:game_id/moves
  # GET api/v1/games/:game_id/moves.json
  def index
    @moves = @game.moves.all
    render json: @moves, status: 200
  end

  # GET api/v1/games/:game_id/moves/1
  # GET api/v1/games/:game_id/moves/1.json
  def show
    render json: @move, status: 200
  end

  # GET api/v1/games/:game_id/moves/new
  def new
    @move = @game.moves.new
    @move.move_number = @game.move_counter + 1
    @move.player_id = @game.player_id_whose_move_it_is
    render json: @move.as_json(only: [:game_id, :player_id]), status: 200
  end

  # POST api/v1/games/:game_id/moves
  # POST api/v1/games/:game_id/moves.json
  def create
    @move = Move.new(move_params)
    @move.attack_coords.strip!
    @move.attack_coords.upcase!
    @move.attack_coords.sub!(/^(\d+)([A-J])$/, '\2\1') # replace "5F" with "F5"

    if @game.players_turn?(@move.player_id)
      defending_player_id = @game.other_player_id(@move.player_id)
  
      move_status = @game.record_hit!(@move.attack_coords, defending_player_id)
      @move.update(move_status)
    
# TODO: in Game#record_hit! take out self.save and add in increment_move_counters
#       and only save game changes if the move was successfully saved.
  
      if @move.save
        @game.increment_move_counters!
        render json: @move, status: 200
      else
        render json: @move.errors, status: :unprocessable_entity
      end
    else
      # TODO: Actually, with varying game state's, it might not be the other player's turn, maybe the game is waiting to join or game over.
      Rails.logger.debug "CdLB: moves#create player #{@move.player_id} tried to play, but it's #{@game.player_id_whose_move_it_is}'s turn"
      @move.errors.add(:error, "Player ID (#{@move.player_id})) does not match whose turn it is (#{@game.player_id_whose_move_it_is})" )
      render json: @move.errors, status: :locked
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:game_id])
    end

    def set_move
      @move = @game.moves.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def move_params
      params.require(:move).permit(:game_id, :player_id, :attack_coords).tap do |move_params|
        move_params.require(:game_id)
        move_params.require(:player_id)
        move_params.require(:attack_coords)
      end
    end
end
