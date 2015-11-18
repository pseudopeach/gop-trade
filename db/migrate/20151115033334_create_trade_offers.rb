class CreateTradeOffers < ActiveRecord::Migration
  def change
    create_table :trade_offers do |t|

        t.integer :candidate_id, null: false
        t.integer :offerer_id, null: false
        t.integer :bid_price
        t.integer :ask_price
        t.integer :qty_available
        t.timestamp :closed_at

        t.timestamps

    end
  end
end
