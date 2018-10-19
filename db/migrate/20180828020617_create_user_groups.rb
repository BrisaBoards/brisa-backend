class CreateUserGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :user_groups do |t|
      t.string :owner_uid
      t.string :name
      t.jsonb :access
      t.jsonb :settings
      t.timestamps
    end
    add_index :user_groups, :owner_uid, unique: false
  end
end
