class AddIndexToReserves < ActiveRecord::Migration
  def change
    add_index :reserves, [:resource_id, :owner_id], unique: true
  end
end
