class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.string :id_name, :length => 32
      t.string :name
      t.timestamp :dropped_out_at
    end
    add_index :candidates, :id_name, :unique => true
  end
end
