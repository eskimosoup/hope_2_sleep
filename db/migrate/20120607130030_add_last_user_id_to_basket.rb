class AddLastUserIdToBasket < ActiveRecord::Migration
  def self.up
    add_column :baskets, :last_user_id, :integer
  end

  def self.down
    remove_column :baskets, :last_user_id
  end
end
