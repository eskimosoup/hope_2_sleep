class AddNameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_names, :string
    add_column :users, :surname, :string
  end

  def self.down
    remove_column :users, :surname
    remove_column :users, :first_names
  end
end
