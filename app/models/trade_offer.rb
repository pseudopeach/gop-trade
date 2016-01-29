class TradeOffer < ActiveRecord::Base
  attr_accessor :qty_possible
  belongs_to :offerer, class_name: "User", inverse_of: :offers
  belongs_to :candidate

  validates_numericality_of :qty_authorized, on: :create, :greater_than_or_equal_to => 1
  validate :bid_or_ask

  def execute(share_count, transacting_user)
    if bid_price
      buyer = User.find offerer_id
      seller = transacting_user
      # seller must have enough shares
      share_count_adj = [transacting_user.reserve_qty(resource_id: candidate_id) , share_count].min
    else
      buyer = transacting_user
      seller = User.find offerer_id
      # buyer must have enough money
      share_count_adj = [transacting_user.reserve_qty(resource_id: 0)/ask_price , share_count].min
    end

    return nil unless share_count_adj > 0

    success = generate_trade share_count_adj, buyer: buyer, seller: seller

    if share_count > share_count_adj && success
      offer = TradeOffer.from_other self
      offer.qty_authorized = share_count - share_count_adj
      offer.adjust_availability
      offer.save
    end

    success
  end

  def self.from_other(other)
    TradeOffer.new offerer: other.offerer, candidate: other.candidate,
                       bid_price: other.bid_price, ask_price: other.ask_price

  end

  def generate_trade(share_count, buyer: nil, seller: nil)
    price = bid_price || ask_price

    transaction_complete = false
    trade = nil
    self.transaction do
      self.closed_at = 0.seconds.ago
      self.qty_authorized -= share_count
      self.qty_available = qty_authorized

      #move the shares
      seller.reserve_debit share_count: share_count, resource_id: candidate_id
      buyer.reserve_credit share_count: share_count, resource_id: candidate_id

      #move the money
      seller.reserve_credit share_count: share_count*price, resource_id: 0
      buyer.reserve_debit share_count: share_count*price, resource_id: 0

      #create the trade record
      trade = Trade.create! qty: share_count, price_cents: price, candidate_id: candidate_id,
                    executed_at: 0.seconds.ago, seller_id: seller.id, buyer_id: buyer.id

      #update offer qtys to make sure they can be covered
      buyer.update_qtys
      seller.update_qtys

      #cache the prices
      candidate.populate_prices

      self.save!
      if qty_available < 0
        raise ActiveRecord::Rollback, "Trade not available"
      end
      transaction_complete = true
    end

    return transaction_complete ? trade : nil
  end

  def adjust_availability(owner_share_qty:nil, owner_cash:nil)
    unless owner_share_qty && owner_cash
      h = offerer.reserve_qty
      owner_share_qty, owner_cash = h[candidate_id], h[0]
    end
    if ask_price
      if !qty_available || qty_available > owner_share_qty || qty_available < qty_authorized

        # for sell offers, make sure there's enough shares to cover
        self.qty_available = [owner_share_qty, qty_authorized].min
      end
    else
      if !qty_available || owner_cash < (qty_authorized * bid_price) || qty_available < qty_authorized

        # make sure there's enough money to cover the buy offers
        self.qty_available = [owner_cash / bid_price, qty_authorized].min
      end
    end
  end

  def close_out
    self.closed_at = 0.seconds.ago
    save!
  end

  def usurp(other_offer)
    completed = false
    self.transaction do
      self.save!
      other_offer.close_out
      completed = true
    end
    completed
  end

  private
  def bid_or_ask
    unless bid_price || ask_price
      errors.add(:bid_price, "Must have a bid or ask price.")
      errors.add(:ask_price, "Must have a bid or ask price.")
    end

  end
end
