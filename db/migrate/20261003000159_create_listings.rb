class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.references :property, null: false, foreign_key: true
      t.string     :title, null: false, limit: 150
      t.string     :status, null: false, default: "draft"
      t.integer    :minimum_stay_days
      t.decimal    :monthly_rent, precision: 10, scale: 2, null: false
      t.decimal    :deposit, precision: 10, scale: 2, null: false, default: 0
      t.boolean    :is_furnished, null: false, default: false
      t.boolean    :has_private_bathroom, null: false, default: false
      t.text       :description
      t.text       :house_rules
      t.date       :available_from, null: false
      t.datetime   :published_at

      t.timestamps
    end

    add_index :listings, :status
    add_index :listings, :available_from
  end
end
