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

  def price_chart_data(max_height: 100)
    trade_points = trades.order(:executed_at)

    scale = max_height.to_f / 100

    i = 0
    day = trade_points.first.executed_at.at_midnight
    day_count = ((0.seconds.ago - day) / 3600 / 24).to_i

    chart_prices = []
    (0...day_count).each do |_|
      chart_prices << {'price' => trade_points[i].price_cents * scale}
      day += 1.day
      while (i + 1) < trade_points.length && day > trade_points[i].executed_at
        i += 1
      end
    end

    chart_prices
  end

end
