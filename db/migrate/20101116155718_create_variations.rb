class CreateVariations < ActiveRecord::Migration
  def self.up
    create_table :variations do |t|

      t.integer :stock

      t.string :option_1

      t.string :option_2

      t.string :option_3

      t.integer :product_id

      t.timestamps
      t.integer :created_by
      t.integer :updated_by
      t.boolean :recycled, :default => false
      t.datetime :recycled_at
      t.boolean :display, :default => true
      t.integer :position, :default => 0
    end
  end
  
  def self.down
    drop_table :variations
  end
end