class CreateEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :entries do |t|
      t.string :owner_uid
      t.string :creator_uid
      t.integer :group_id
      t.string :title
      t.text :description
      t.string :tags, array: true
      t.string :classes, array: true
      t.jsonb :metadata
      t.timestamps
    end
    add_index :entries, :owner_uid
    add_index :entries, :creator_uid
    add_index :entries, :group_id, unique: false
    add_index :entries, :tags, using: 'gin'
    add_index :entries, :classes, using: 'gin'
  end
end
