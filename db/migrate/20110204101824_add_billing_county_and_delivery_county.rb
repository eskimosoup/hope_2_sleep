class AddBillingCountyAndDeliveryCounty < ActiveRecord::Migration
  def self.up
    add_column :baskets, :billing_county, :string, :default => ""
    add_column :orders, :billing_county, :string, :default => ""
    add_column :baskets, :delivery_county, :string, :default => ""
    add_column :orders, :delivery_county, :string, :default => ""
  end

  def self.down
    remove_column :baskets, :billing_county
    remove_column :orders, :billing_county
    remove_column :baskets, :delivery_county
    remove_column :orders, :delivery_county
  end
end
