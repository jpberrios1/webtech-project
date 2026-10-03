class CreateAmenities < ActiveRecord::Migration[8.1]
  def change
    create_table :amenities do |t|
      t.string :name, null: false, limit: 80, index: { unique: true }
      t.text   :description

      t.timestamps
    end
  end
end
