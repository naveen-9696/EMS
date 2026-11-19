class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :status
      t.string :phase

      # Devise
      t.string :encrypted_password, null: false, default: ""
      t.references :role, type: :uuid, foreign_key: true
      t.timestamps

      t.index :email, unique: true
    end
  end
end
