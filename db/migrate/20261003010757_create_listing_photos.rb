class CreateListingPhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :listing_photos do |t|
      t.references :listing, null: false, foreign_key: true
      t.string     :url, null: false, limit: 500
      t.string     :caption, limit: 255

      t.timestamps
    end
  end
end
