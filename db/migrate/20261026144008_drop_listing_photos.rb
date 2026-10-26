class DropListingPhotos < ActiveRecord::Migration[8.1]
  def change
    drop_table :listing_photos do |t|
      t.references :listing, null: false, foreign_key: true
      t.string :url, limit: 500, null: false
      t.string :caption, limit: 255
      t.timestamps
    end
  end
end
