class TradesController < ApplicationController
  before_action :force_session
  before_action :set_trade, only: [:edit, :update, :execute, :destroy]


  def index
    @user = User.find session[:user_id]
    @open_offers = @user.offers.where(closed_at:nil).includes(:candidate).order(updated_at: :asc)
  end

  # GET /trades/1
  # GET /trades/1.json
  def show
    @candidate = Candidate.where(id_name: params[:id_name]).first
    render file: 'public/404', status: :not_found, layout:false unless @candidate

    @recent_trades = Trade.where(candidate_id: @candidate.id).order(executed_at: :desc).limit(10)

    @user_offers = TradeOffer.where(offerer_id: session[:user_id], candidate_id: @candidate.id)

    @bids = TradeOffer.where(closed_at: nil, candidate_id:@candidate.id).where('bid_price > 0')
    @asks = TradeOffer.where(closed_at: nil, candidate_id:@candidate.id).where('ask_price > 0')

  end

  # GET /trades/new
  def new
    @trade_offer = TradeOffer.new
    set_edit_options
  end

  # GET /trades/1/edit
  def edit
    set_edit_options
  end

  # POST /trades
  # POST /trades.json
  def create
    @trade_offer = TradeOffer.new(trade_params)
    @trade_offer.offerer_id = session[:user_id]
    @trade_offer.qty_available = @trade_offer.qty_authorized
    null_other_price(@trade_offer)

    respond_to do |format|
      if @trade_offer.candidate && @trade_offer.save
        format.html do
          flash[:notice] = 'Trade was successfully created.'
          redirect_to controller: :trades, action: :show,
                      id_name:@trade_offer.candidate.id_name
        end
        format.json { render :show, status: :created, location: @trade_offer }
      else
        set_edit_options
        format.html { render :new }
        format.json { render json: @trade_offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trades/1
  # PATCH/PUT /trades/1.json
  def update
    @trade_offer.qty_available = @trade_offer.qty_authorized
    null_other_price(@trade_offer)
    respond_to do |format|
      if @trade_offer.update(trade_params)
        flash[:notice] = 'Trade was successfully updated.'
        format.html do
          redirect_to controller: :trades, action: :show, id_name:@trade_offer.candidate.id_name
        end
        format.json { render :show, status: :ok, location: @trade_offer }
      else
        set_edit_options
        format.html { render :edit }
        format.json { render json: @trade_offer.errors, status: :unprocessable_entity }
      end
    end
  end

  def execute
    qty = params[:qty].to_i
    unless qty > 0
      render file: 'public/422', status: :unprocessable_entity
      return
    end

    if @trade_offer.execute(qty, User.find(session[:user_id]))
      flash[:notice] = 'Trade was successfully executed!'
      respond_to do |format|
        format.html do
          redirect_to(controller: :trades, action: :show, id_name:@trade_offer.candidate.id_name)
        end
        format.json { render :show, status: :ok, location: @trade_offer }
      end
    else
      flash[:error] = "Trade couldn't be completed :("
      respond_to do |format|
        format.html do
          redirect_to(controller: :trades, action: :show, id_name:@trade_offer.candidate.id_name)
        end
        format.json { render :show, status: :ok, location: @trade_offer }
      end
    end
  end

  # DELETE /trades/1
  # DELETE /trades/1.json
  def destroy
    @trade_offer.close_out
    respond_to do |format|
      format.html { redirect_to trades_url, notice: 'Trade was successfully destroyed.' }
      format.json {render json: {offer_closed_at: @trade_offer.closed_at} }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trade
      @trade_offer = TradeOffer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trade_params
      params.require(:trade_offer).permit [:candidate_id, :qty_authorized, :bid_price, :ask_price]
    end

    def force_session
      session[:user_id] = 1
    end

    def trade_offers_path
      trades_path
    end

    def set_edit_options
      if candidate_id = params[:selected_candidate]
        max_sell_qty = User.find(session[:user_id]).reserve_qty resource_id: candidate_id
      end

      @candidate_options = Candidate.all.map{|c| [ c.name, c.id]}
      if @trade_offer.new_record?
        @trade_offer.candidate_id = params[:selected_candidate]
        @trade_offer.qty_available = max_sell_qty || 1
        @is_buying = params[:sell].nil?
      else
        @is_buying = @trade_offer.bid_price?
      end
      @qty_options = (1..max_sell_qty || 30).to_a.map{|d| [d, d]}
      @price_options = (0..100).to_a.map{|d| [d, d]}

    end

    def null_other_price(offer)
      if params[:buysell] == 'sell'
        offer.bid_price = nil
      else
        offer.ask_price = nil
      end
    end
end
