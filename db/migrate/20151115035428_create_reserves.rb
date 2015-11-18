class CreateReserves < ActiveRecord::Migration
  def change
    create_table :reserves do |t|
      t.integer :resource_id, null: false
      t.integer :owner_id, null: false
      t.integer :qty, null: false

      t.timestamp :executed_at
    end
  end
end
