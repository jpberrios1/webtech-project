class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :visit, null: false, foreign_key: true, index: { unique: true }
      t.references :property, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer    :rating, null: false
      t.text       :comment

      t.timestamps
    end
  end
end
