class AddUserIndexes < ActiveRecord::Migration
  def change
    add_index :trades, :buyer_id
    add_index :trades, :seller_id
    add_index :trades, :candidate_id

    add_index :trade_offers, :offerer_id
    add_index :trade_offers, :candidate_id

    add_index :reserves, :owner_id
  end
end
