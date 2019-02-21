class AddAssigneeAndWatchersToEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :watchers, :string, array: true, default: []
    add_column :entries, :assignees, :string, array: true, default: []
    add_index :entries, :assignees
  end
end
