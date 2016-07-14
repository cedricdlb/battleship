class Api::V1::MovesController < Api::V1::BaseController
  before_action :set_game #, only: [:show, :new, :create, :edit, :update, :join, :destroy]
  before_action :set_move, only: [:show, :edit, :update, :destroy]
 #before_action :set_move, only: [:show,                 :destroy]

  # GET /games/:game_id/moves
  # GET /games/:game_id/moves.json
  def index
    @moves = @game.moves.all
  end

  # GET /games/:game_id/moves/1
  # GET /games/:game_id/moves/1.json
  def show
  end

  # GET /games/:game_id/moves/new
  def new
    @move = @game.moves.new
    @move.move_number = @game.move_counter + 1
    @move.player_id = @game.player_id_whose_move_it_is
  end

  # GET /games/:game_id/moves/1/edit
  def edit
  end

  # POST /games/:game_id/moves
  # POST /games/:game_id/moves.json
  def create
    @move = Move.new(move_params)
    @move.attack_coords.strip!
    @move.attack_coords.upcase!

    if @game.players_turn?(@move.player_id)
      defending_player_id = @game.other_player_id(@move.player_id)
  
      move_status = @game.record_hit!(@move.attack_coords, defending_player_id)
      @move.update(move_status)
  
      respond_to do |format|
        if @move.save
          @game.increment_move_counters!
# TODO: in Game#record_hit! take out self.save and add in increment_move_counters
#       and only save game changes if the move was successfully saved.
#         format.html { redirect_to [@game, @move], notice: @move.message }
          format.json { render :show, status: :created, location: @move }
        else
#         format.html { render :new }
          format.json { render json: @move.errors, status: :unprocessable_entity }
        end
      end
    else
      Rails.logger.debug "CdLB: moves#create player #{@move.player_id} tried to play, but it's #{@game.player_id_whose_move_it_is}'s turn"
      flash[:alert] = "Admiral, we can't fire, we're still reloading guns! (Please wait for your turn.)" 
      @move.errors.messages[:player_id] ||= []
      @move.errors.details[:player_id]  ||= []
      @move.errors.messages[:player_id] << "ID (#{@move.player_id}) does not match whose turn it is (#{@game.player_id_whose_move_it_is})"
      @move.errors.details[:player_id]  << {error: :not_players_turn, value: @move.player_id}
      respond_to do |format|
#       format.html { render :new, status: :locked, notice: "Admiral, we can't fire, we're still reloading guns! (Please wait for your turn.)" }
       #format.json { render json: @move.errors, status: :unprocessable_entity }
        format.json { render json: @move.errors, status: :locked }
      end
    end
  end

  # PATCH/PUT /games/:game_id/moves/1
  # PATCH/PUT /games/:game_id/moves/1.json
  def update
    respond_to do |format|
      if @move.update(move_params)
#       format.html { redirect_to [@game, @move], notice: 'Move was successfully updated.' }
        format.json { render :show, status: :ok, location: @move }
      else
#       format.html { render :edit }
        format.json { render json: @move.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/:game_id/moves/1
  # DELETE /games/:game_id/moves/1.json
  def destroy
    @move.destroy
    respond_to do |format|
#     format.html { redirect_to game_moves_path(@game), notice: 'Move was successfully destroyed.' }
      format.json { head :no_content }
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
      params.require(:move).permit(:game_id, :player_id, :move_number, :attack_coords, :hit, :ship_part_hit, :ship_sunk, :fleet_sunk)
    end
end
