class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :status, :update, :join, :destroy]
  before_action :trim_blanks_from_fleet_coords, only: [:update]

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
    @game = Game.new(&:init_game)
  end

  # GET /games/1/edit
  def edit
  end

  # GET /games/1/status
  def status
    @last_move = @game.moves.where(move_number: @game.move_counter).first
    respond_to do |format|
      format.html { render :status, notice: @game.game_state_message }
      format.json { render :status } #, status: :created, location: @game }
    end
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    @game.player_1_fleet_coords -= [""] if @game.player_1_fleet_coords
    @game.player_2_fleet_coords -= [""] if @game.player_2_fleet_coords

    # TODO: Use Action Cable to keep channel open to player_1

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: @game.game_state_message }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /games/1/join
  # PATCH /games/1/join.json
  def join
    # TODO: Use Action Cable to Keep channel open to player
    # TODO: Use Action Cable to Message player_1 that it's their turn to start

    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: @game.game_state_message }
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
      params.require(:game).permit(:title, :player_1_id, :player_2_id, :whose_move, :move_counter, :player_1_fleet_status, :player_2_fleet_status, :player_1_fleet_coords => [], :player_2_fleet_coords => [])
    end
  
    def trim_blanks_from_fleet_coords
      params[:game][:player_1_fleet_coords] -= [""] if params[:game][:player_1_fleet_coords]
      params[:game][:player_2_fleet_coords] -= [""] if params[:game][:player_2_fleet_coords]
    end

end
