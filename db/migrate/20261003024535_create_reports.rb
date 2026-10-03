class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :reviewer, foreign_key: { to_table: :users }
      t.string     :reason, null: false
      t.string     :status, null: false, default: "pending"
      t.text       :description
      t.datetime   :reviewed_at

      t.timestamps
    end

    add_index :reports, :status
  end
end
