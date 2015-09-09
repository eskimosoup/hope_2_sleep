class AddWeightsToShippingOptions < ActiveRecord::Migration
  def self.up
    add_column :shipping_options, :min_weight, :integer
    add_column :shipping_options, :max_weight, :integer
  end

  def self.down
    remove_column :shipping_options, :max_weight
    remove_column :shipping_options, :min_weight
  end
end
