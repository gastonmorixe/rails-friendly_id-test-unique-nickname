class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :slug

      t.timestamps
    end
    add_index :users, :slug, unique: true
  end
end
