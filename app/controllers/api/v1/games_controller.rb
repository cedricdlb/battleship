class Api::V1::GamesController < Api::V1::BaseController
  before_action :set_game, only: [:show, :status, :update, :destroy]

  # GET api/v1/games
  # GET api/v1/games.json
  def index
    @games = Game.all
    render json: @games, status: 200
  end

  # GET api/v1/games/1
  # GET api/v1/games/1.json
  def show
    render json: @game, status: 200
  end

  # GET api/v1/games/new
  def new
    @game = Game.new(&:init_game)
    render json: @game, status: 200
  end

  # GET api/v1/games/1/status
  def status
    @last_move = @game.moves.where(move_number: @game.move_counter).first
    render json: @game.as_json(only: [:id, :title, :player_1_id, :player_2_id, :whose_move, :move_counter, :created_at, :updated_at]).
                       merge(game_state: @game.game_state, game_state_message: @game.game_state_message).
                       merge(last_move: @last_move.try(:as_json) || {}), status: 200
  end

  # POST api/v1/games
  # POST api/v1/games.json
  def create
    @game = Game.new(game_params)
    @game.save!
    render json: @game, status: :created
  end

  # PATCH/PUT api/v1/games/1
  # PATCH/PUT api/v1/games/1.json
  def update
    @game.update!(game_params)          # anticipated possible exceptions rescued in BaseController
    render json: @game, status: 200
  end

  # DELETE api/v1/games/1
  # DELETE api/v1/games/1.json
  def destroy
    @game.destroy
    render json: @game.as_json.merge(deleted_at: Time.now.utc.iso8601), status: 200
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:title, :player_1_id, :player_2_id, :whose_move, :move_counter, :player_1_fleet_status, :player_2_fleet_status, :player_1_fleet_coords => [], :player_2_fleet_coords => [])
    end
end
