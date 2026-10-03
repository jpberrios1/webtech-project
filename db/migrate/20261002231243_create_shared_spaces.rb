class CreateSharedSpaces < ActiveRecord::Migration[8.1]
  def change
    create_table :shared_spaces do |t|
      t.string :name, limit: 80
      t.text :description

      t.timestamps
    end
  end
end
