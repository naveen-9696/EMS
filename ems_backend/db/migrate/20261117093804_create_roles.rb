class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :name, null: false
      t.references :department, type: :uuid, foreign_key: true

      t.timestamps

      t.index :name, unique: true
    end
  end
end
