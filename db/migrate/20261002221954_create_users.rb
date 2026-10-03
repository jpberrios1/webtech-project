class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false, limit: 120
      t.string :email_address, null: false, limit: 255, index: { unique: true }
      t.string :password_digest, null: false, limit: 255
      t.string :phone, limit: 30
      t.string :role, null: false, default: "member"

      t.timestamps
    end
  end
end
