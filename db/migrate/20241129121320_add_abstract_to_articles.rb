class AddAbstractToArticles < ActiveRecord::Migration[7.2]
  def change
    add_column :articles, :abstract, :text
  end
end
