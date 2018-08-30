class CreateUserModels < ActiveRecord::Migration[5.2]
  def change
    create_table :user_models do |t|
      t.integer :owner_id
      t.integer :group_id
      t.string :title
      t.jsonb :config
      t.string :unique_id
      t.timestamps
    end
    add_index :user_models, :owner_id
    add_index :user_models, :group_id
  end
end
