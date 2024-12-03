class ChangeVersionsColumnsToJson < ActiveRecord::Migration[7.2]
  def up
    change_column :versions, :object, :jsonb, using: 'object::jsonb'
    change_column :versions, :object_changes, :jsonb, using: 'object_changes::jsonb'
  end

  def down
    change_column :versions, :object, :text
    change_column :versions, :object_changes, :text
  end
end 