class AddIndexToCategories < ActiveRecord::Migration[7.0]
  def change
    add_index :categories, [ :name, :user_id ], unique: true
  end
end
