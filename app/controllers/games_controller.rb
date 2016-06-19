class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :join, :destroy]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    # Keep channel open to player_1

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created, waiting for player 2.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1/join
  # PATCH/PUT /games/1/join.json
  def join
    @game.player_2 = game_params["player_id"] if game_params["player_id"] && !@game.player_2

    # Keep channel open to player_2
    # Message player_1 that it's their turn to start

    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: "You have successfully joined the game #{game.title}." }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:title, :player_1_id, :player_2_id, :player_1_fleet_status, :player_2_fleet_status, :player_1_fleet_coords, :player_2_fleet_coords)
    end
end
