class AddFieldsToEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :archived, :boolean
    add_column :entries, :due_at, :datetime
    add_column :entries, :start_at, :datetime
    add_column :entries, :time_est, :integer
    add_column :entries, :completed_at, :datetime
  end
end
