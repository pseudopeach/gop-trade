class AddPriceColumnsToCandidates < ActiveRecord::Migration
  def change
    add_column :candidates, :latest_price, :integer
    add_column :candidates, :latest_price_delta, :integer
  end
end
