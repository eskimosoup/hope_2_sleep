class AddProductIdToPageContents < ActiveRecord::Migration
  def self.up
    add_column :page_contents, :product_id, :integer
  end

  def self.down
    remove_column :page_contents, :product_id
  end
end
