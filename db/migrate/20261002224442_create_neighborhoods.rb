class CreateNeighborhoods < ActiveRecord::Migration[8.1]
  def change
    create_table :neighborhoods do |t|
      t.string :name, null: false, limit: 120
      t.string :city, null: false, limit: 120

      t.timestamps
    end

    add_index :neighborhoods, [ :name, :city ], unique: true
  end
end
