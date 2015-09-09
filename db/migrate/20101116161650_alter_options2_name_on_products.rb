class AlterOptions2NameOnProducts < ActiveRecord::Migration
  def self.up
    remove_column :products, :options_2_name
    add_column :products, :option_2_name, :string
  end

  def self.down
    remove_column :products, :option_2_name
    add_column :products, :options_2_name, :string
  end
end
