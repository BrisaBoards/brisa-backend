class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.string :parent
      t.string :ctx
      t.jsonb :messages
      t.boolean :is_read

      t.timestamps
    end

    add_index :notifications, :user_id
    add_index :notifications, :parent
  end
end
