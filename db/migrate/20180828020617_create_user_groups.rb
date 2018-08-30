class CreateUserGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :user_groups do |t|
      t.integer :user_id
      t.string :name
      t.jsonb :access
      t.timestamps
    end
    add_index :user_groups, :user_id
  end
end
