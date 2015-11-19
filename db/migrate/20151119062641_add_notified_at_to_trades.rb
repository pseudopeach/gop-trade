class AddNotifiedAtToTrades < ActiveRecord::Migration
  def change
    add_column :trades, :notified_at, :timestamp
  end
end
