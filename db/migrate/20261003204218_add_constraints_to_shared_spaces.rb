class AddConstraintsToSharedSpaces < ActiveRecord::Migration[8.1]
  def change
    change_column_null :shared_spaces, :name, false
    add_index :shared_spaces, :name, unique: true
  end
end
