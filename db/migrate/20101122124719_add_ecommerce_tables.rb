class AddEcommerceTables < ActiveRecord::Migration
  def self.up
    create_table "addresses", :force => true do |t|
      t.string   "surname"
      t.string   "first_names"
      t.string   "address_1"
      t.string   "address_2"
      t.string   "city"
      t.string   "postcode"
      t.string   "country"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.boolean  "recycled",    :default => false
      t.datetime "recycled_at"
      t.boolean  "display",     :default => true
      t.integer  "position",    :default => 0
    end
    
    create_table "newsletter_subscribers", :force => true do |t|
      t.string   "email"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.boolean  "recycled",    :default => false
      t.datetime "recycled_at"
      t.boolean  "display",     :default => true
      t.integer  "position",    :default => 0
    end

    create_table "order_items", :force => true do |t|
      t.integer  "order_id"
      t.integer  "variation_id"
      t.integer  "amount"
      t.float    "subtotal",     :default => 0.0
      t.string   "product_name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.boolean  "recycled",     :default => false
      t.datetime "recycled_at"
      t.boolean  "display",      :default => true
      t.integer  "position",     :default => 0
    end

    create_table "orders", :force => true do |t|
      t.integer  "user_id"
      t.float    "delivery_subtotal",     :default => 0.0
      t.float    "discount_subtotal",     :default => 0.0
      t.float    "products_subtotal",     :default => 0.0
      t.float    "total",                 :default => 0.0
      t.string   "delivery_summary"
      t.string   "billing_surname"
      t.string   "billing_first_names"
      t.string   "billing_address_1"
      t.string   "billing_address_2"
      t.string   "billing_city"
      t.string   "billing_postcode"
      t.string   "billing_country"
      t.string   "delivery_surname"
      t.string   "delivery_first_names"
      t.string   "delivery_address_1"
      t.string   "delivery_address_2"
      t.string   "delivery_city"
      t.string   "delivery_postcode"
      t.string   "delivery_country"
      t.string   "user_email"
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.boolean  "recycled",              :default => false
      t.datetime "recycled_at"
      t.boolean  "display",               :default => true
      t.integer  "position",              :default => 0
      t.string   "online_invoice_number"
      t.float    "gift_wrap_subtotal",    :default => 0.0
      t.text     "gift_wrap_message"
      t.text     "gateway_reply"
    end

    create_table "price_ranges", :force => true do |t|
      t.float    "start",       :default => 0.0
      t.float    "end",         :default => 0.0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.boolean  "recycled",    :default => false
      t.datetime "recycled_at"
      t.boolean  "display",     :default => true
      t.integer  "position",    :default => 0
    end

    create_table "product_associations", :id => false, :force => true do |t|
      t.integer "first_product_id"
      t.integer "second_product_id"
    end
    
    create_table "products_promo_codes", :id => false, :force => true do |t|
      t.integer "product_id"
      t.integer "promo_code_id"
    end

    create_table "promo_codes", :force => true do |t|
      t.string   "name"
      t.string   "code"
      t.date     "start_date",      :default => '2010-11-01'
      t.date     "end_date"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.boolean  "recycled",        :default => false
      t.datetime "recycled_at"
      t.boolean  "display",         :default => true
      t.integer  "position",        :default => 0
      t.string   "promo_code_type"
      t.float    "amount_off"
      t.integer  "percentage_off"
    end

    create_table "promo_codes_shipping_options", :id => false, :force => true do |t|
      t.integer "promo_code_id"
      t.integer "shipping_option_id"
    end

    create_table "shipping_options", :force => true do |t|
      t.string   "name"
      t.float    "price"
      t.string   "region"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "created_by"
      t.integer  "updated_by"
      t.boolean  "recycled",    :default => false
      t.datetime "recycled_at"
      t.boolean  "display",     :default => true
      t.integer  "position",    :default => 0
    end
  
  end

  def self.down
    drop_table "addresses"
    drop_table "newsletter_subscribers"
    drop_table "order_items"
    drop_table "orders"
    drop_table "price_ranges"
    drop_table "product_associations"
    drop_table "products_promo_codes"
    drop_table "promo_codes"
    drop_table "promo_codes_shipping_options"
    drop_table "shipping_options"
  end
end
