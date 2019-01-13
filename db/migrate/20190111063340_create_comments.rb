class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :entry_id
      t.string :user_uid
      t.text :comment
      t.string :reply_to
      t.boolean :deleted

      t.timestamps
    end
    add_index :comments, :entry_id
  end
end
