class AddCategoryToArticles < ActiveRecord::Migration[7.2]
  def change
    add_reference :articles, :category, null: true, foreign_key: true
  end
end
