class CreateBasketItems < ActiveRecord::Migration
  def self.up
    create_table "basket_items", :force => true do |t|
      t.integer  "basket_id"
      t.integer  "variation_id"
      t.integer  "amount",     :default => 1
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table "basket_items"
  end
end
