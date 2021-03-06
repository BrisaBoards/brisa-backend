class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :uid, unique: true
      t.string :alias
      t.string :email, unique: true
      t.boolean :confirmed
      t.boolean :disabled
      t.string :disabled_message
      t.boolean :admin
      t.string :encrypted_password
      t.timestamps
    end
    add_index :users, :email
  end
end
