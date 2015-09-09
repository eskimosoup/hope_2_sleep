class CreateBaskets < ActiveRecord::Migration
  def self.up
    create_table :baskets do |t|

      t.integer :user_id

      t.string :delivery_summary

      t.string :billing_surname

      t.string :billing_first_names

      t.string :billing_address_1

      t.string :billing_address_2

      t.string :billing_city

      t.string :billing_postcode

      t.string :billing_country

      t.string :delivery_surname

      t.string :delivery_first_names

      t.string :delivery_address_1

      t.string :delivery_address_2

      t.string :delivery_city

      t.string :delivery_postcode

      t.string :delivery_country

      t.text :gift_wrap_message

      t.boolean :gift_wrap

      t.integer :promo_code_id

      t.integer :shipping_option_id

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
    drop_table :baskets
  end
end