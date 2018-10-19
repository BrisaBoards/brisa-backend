class CreateUserModels < ActiveRecord::Migration[5.2]
  def change
    create_table :user_models do |t|
      t.string :owner_uid
      t.integer :group_id
      t.string :title
      t.jsonb :config
      t.string :unique_id
      t.timestamps
    end
    add_index :user_models, :owner_uid
    add_index :user_models, :group_id
  end
end
