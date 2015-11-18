class FixColumnNameOnReserves < ActiveRecord::Migration
  def change
    rename_column :reserves, :executed_at, :updated_at
  end
end
