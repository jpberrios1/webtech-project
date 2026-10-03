class CreateApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :applications do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :seeker, null: false, foreign_key: { to_table: :users }
      t.text       :message, null: false
      t.date       :desired_move_in_date, null: false
      t.integer    :length_of_stay_days, null: false
      t.string     :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :applications, [ :listing_id, :seeker_id ], unique: true
    add_index :applications, :status
  end
end
