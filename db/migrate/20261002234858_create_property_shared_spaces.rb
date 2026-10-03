class CreatePropertySharedSpaces < ActiveRecord::Migration[8.1]
  def change
    create_table :property_shared_spaces do |t|
      t.references :property, null: false, foreign_key: true
      t.references :shared_space, null: false, foreign_key: true

      t.timestamps
    end

    add_index :property_shared_spaces, [ :property_id, :shared_space_id ], unique: true
  end
end
