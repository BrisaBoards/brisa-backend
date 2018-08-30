class CreateUserSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_settings do |t|
      t.integer :user_id
      t.string :name
      t.jsonb :setting
      t.timestamps
    end
    add_index :user_settings, :user_id
  end
end
