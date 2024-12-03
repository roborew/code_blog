class AddSubheadingToArticles < ActiveRecord::Migration[7.2]
  def change
    add_column :articles, :subheading, :string
  end
end
