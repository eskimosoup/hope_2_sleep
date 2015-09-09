class AddKeepToBaskets < ActiveRecord::Migration
  def self.up
    add_column :baskets, :keep, :boolean, :default => false
  end

  def self.down
    remove_column :baskets, :keep
  end
end
