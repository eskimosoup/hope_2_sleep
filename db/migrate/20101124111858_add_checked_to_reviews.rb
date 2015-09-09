class AddCheckedToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :checked, :boolean, :default => false
  end

  def self.down
    remove_column :reviews, :checked
  end
end
