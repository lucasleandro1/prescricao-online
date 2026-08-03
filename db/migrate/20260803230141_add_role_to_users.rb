class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string, default: "user", null: false
    add_column :users, :name, :string
  end
end
