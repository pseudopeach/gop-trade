class Candidate < ActiveRecord::Base
  has_many :trades

  def populate_prices
    if (last_trade = trades.last)
      earlier_trade = trades.where("executed_at <= ?", last_trade.executed_at - 1.day).last # at least 1 day prior

      self.latest_price = last_trade.price_cents
      self.latest_price_delta = (latest_price - earlier_trade.price_cents) if earlier_trade
      save!
    end

  end
end
