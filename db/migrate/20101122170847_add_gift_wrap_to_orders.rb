class AddGiftWrapToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :gift_wrap, :boolean
  end

  def self.down
    remove_column :orders, :gift_wrap
  end
end
