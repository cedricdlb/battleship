class Api::V1::PlayersController < Api::V1::BaseController
  before_action :set_player, only: [:show, :update, :destroy]

  # GET api/v1/players
  # GET api/v1/players.json
  def index
    @players = Player.all
    render json: @players, status: 200
  end

  # GET api/v1/players/1
  # GET api/v1/players/1.json
  def show
    render json: @player, status: 200
  end

  # POST api/v1/players
  # POST api/v1/players.json
  def create
    @player = Player.create!(player_params) # anticipated possible exceptions rescued in BaseController
    render json: @player, status: :created
  end

  # PATCH/PUT api/v1/players/1
  # PATCH/PUT api/v1/players/1.json
  def update
    @player.update!(player_params)          # anticipated possible exceptions rescued in BaseController
    render json: @player, status: 200
  end

  # DELETE api/v1/players/1
  # DELETE api/v1/players/1.json
  def destroy
    @player.destroy
    render json: @player.as_json.merge(deleted_at: Time.now.utc.iso8601), status: 200
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:name).tap do |player_params|
        player_params.require(:name)
      end
    end
end
