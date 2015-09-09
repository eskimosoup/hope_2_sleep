class ChangePriceOnProductsToFloat < ActiveRecord::Migration
  def self.up
    remove_column :products, :price
    add_column :products, :price, :float
  end

  def self.down
    remove_column :products, :price
    add_column :products, :price, :string
  end
end
