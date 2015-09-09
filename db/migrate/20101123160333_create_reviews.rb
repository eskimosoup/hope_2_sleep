class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|

      t.integer :product_id

      t.integer :user_id

      t.text :review

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
    drop_table :reviews
  end
end