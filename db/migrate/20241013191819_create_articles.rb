class CreateArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content
      t.datetime :publication_date

      t.timestamps
    end
  end
end
