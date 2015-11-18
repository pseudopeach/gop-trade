class TradeOffer < ActiveRecord::Base
  attr_accessor :qty_possible
  belongs_to :offerer, class_name: "User"
  belongs_to :candidate

  validates_numericality_of :qty_authorized, on: :create, :greater_than_or_equal_to => 1
  validate :bid_or_ask

  def execute(share_count, transacting_user)
    if bid_price
      buyer = User.find offerer_id
      seller = transacting_user
    else
      buyer = transacting_user
      seller = User.find offerer_id
    end

    generate_trade share_count, buyer: buyer, seller: seller
  end

  def generate_trade(share_count, buyer: nil, seller: nil)
    price = bid_price || ask_price

    transaction_complete = false
    self.transaction do
      self.closed_at = 0.seconds.ago if qty_available == share_count
      self.qty_available -= share_count

      seller.reserve_debit share_count: share_count, resource_id: candidate_id
      buyer.reserve_credit share_count: share_count, resource_id: candidate_id

      seller.reserve_credit share_count: share_count*price, resource_id: 0
      buyer.reserve_debit share_count: share_count*price, resource_id: 0

      Trade.create! qty: share_count, price_cents: price, candidate_id: candidate_id,
                    executed_at: 0.seconds.ago, seller_id: seller.id, buyer_id: buyer.id

      buyer.update_qtys
      seller.update_qtys

      self.save!
      if qty_available < 0
        raise ActiveRecord::Rollback, "Trade not available"
      end
      transaction_complete = true
    end

    return transaction_complete
  end

  def close_out
    self.closed_at = 0.seconds.ago
    save!
  end

  private
  def bid_or_ask
    unless bid_price || ask_price
      errors.add(:bid_price, "Must have a bid or ask price.")
      errors.add(:ask_price, "Must have a bid or ask price.")
    end

  end
end
