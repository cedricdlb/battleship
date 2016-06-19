class MovesController < ApplicationController
  before_action :set_move, only: [:show, :edit, :update, :destroy]

  # GET /games/:game_id/moves
  # GET /games/:game_id/moves.json
  def index
    @moves = Move.all
  end

  # GET /games/:game_id/moves/1
  # GET /games/:game_id/moves/1.json
  def show
  end

  # GET /games/:game_id/moves/new
  def new
    @move = Move.new
  end

  # GET /games/:game_id/moves/1/edit
  def edit
  end

  # POST /games/:game_id/moves
  # POST /games/:game_id/moves.json
  def create
    @move = Move.new(move_params)

    respond_to do |format|
      if @move.save
        format.html { redirect_to @move, notice: 'Move was successfully created.' }
        format.json { render :show, status: :created, location: @move }
      else
        format.html { render :new }
        format.json { render json: @move.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/:game_id/moves/1
  # PATCH/PUT /games/:game_id/moves/1.json
  def update
    respond_to do |format|
      if @move.update(move_params)
        format.html { redirect_to @move, notice: 'Move was successfully updated.' }
        format.json { render :show, status: :ok, location: @move }
      else
        format.html { render :edit }
        format.json { render json: @move.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/:game_id/moves/1
  # DELETE /games/:game_id/moves/1.json
  def destroy
    @move.destroy
    respond_to do |format|
      format.html { redirect_to moves_url, notice: 'Move was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_move
      @move = Move.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def move_params
      params.require(:move).permit(:game_id, :player_id, :turn_number, :attack_coords, :hit, :ship_part_hit, :ship_sunk, :fleet_sunk)
    end
end
