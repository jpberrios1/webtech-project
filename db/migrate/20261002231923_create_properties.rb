class CreateProperties < ActiveRecord::Migration[8.1]
  def change
    create_table :properties do |t|
      t.references :user, null: false, foreign_key: true
      t.references :neighborhood, null: false, foreign_key: true
      t.string     :title, null: false, limit: 150
      t.string     :address, null: false, limit: 255
      t.string     :property_type, null: false, default: "other"
      t.integer    :bedrooms, null: false
      t.integer    :bathrooms, null: false

      t.timestamps
    end
  end
end
