class AddTransactionCodeToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :transaction_code, :string
  end

  def self.down
    remove_column :orders, :transaction_code
  end
end
