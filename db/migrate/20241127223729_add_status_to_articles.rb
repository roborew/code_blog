class AddStatusToArticles < ActiveRecord::Migration[7.2]
  def change
    add_column :articles, :status, :string, default: "draft"
    add_index :articles, :status
  end
end
