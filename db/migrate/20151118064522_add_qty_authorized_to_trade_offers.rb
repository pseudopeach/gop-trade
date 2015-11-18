class AddQtyAuthorizedToTradeOffers < ActiveRecord::Migration
  def change
    add_column :trade_offers, :qty_authorized, :integer
  end
end
