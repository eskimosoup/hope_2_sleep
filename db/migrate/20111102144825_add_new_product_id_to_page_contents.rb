class AddNewProductIdToPageContents < ActiveRecord::Migration
	
  def self.up
    add_column :page_contents, :new_product_id, :integer
  end
	
  def self.down
    remove_column :page_contents, :new_product_id
  end
  
end
