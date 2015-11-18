class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.integer :candidate_id, null: false
      t.integer :buyer_id, null: false
      t.integer :seller_id, null: false
      t.integer :qty, null: false
      t.integer :price_cents, null: false

      t.timestamp :executed_at
    end
  end
end
