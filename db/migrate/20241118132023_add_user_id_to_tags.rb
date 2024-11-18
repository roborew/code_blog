class AddUserIdToTags < ActiveRecord::Migration[7.2]
  def change
    add_reference :tags, :user, null: true, foreign_key: true
  end
end
