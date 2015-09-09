class Order < ActiveRecord::Base
	
	acts_as_eskimagical
	
	serialize :gateway_reply
	
	has_many :order_items, :dependent => :destroy
	belongs_to :user
  
	named_scope :position, :order => "position"
  named_scope :active, :conditions => ["recycled = ? AND display = ?", false, true]
  named_scope :recycled, :conditions => ["recycled = ?", true]
  named_scope :unrecycled, :conditions => ["recycled = ?", false]
  
  named_scope :type, lambda{|type| { :conditions => ["type LIKE %?%", type] } }
  named_scope :created_in, lambda{|date| { :conditions => ["year(created_at) = ? AND month(created_at) = ?", date.split('-').first, date.split('-').last] } }
  
  before_create :generate_online_invoice_number
  
  def active?
  	display? && !recycled?
  end
  
  def generate_online_invoice_number
    previous_invoice_number = Order.all.collect{|x| x.online_invoice_number.gsub(/\D/, '').to_i}.max
    if previous_invoice_number
      invoice_number = previous_invoice_number + 1
    else
      invoice_number = 10001 
    end
    self.online_invoice_number = "I#{invoice_number}"
  end
  
  def restore_stock
    for order_item in order_items
      order_item.restore_stock
    end
  end
  
  def billing_name
    "#{billing_first_names} #{billing_surname}"
  end
  
  def delivery_name
    "#{delivery_first_names} #{delivery_surname}"
  end
  
  def update_from_paypal_params(params)
    self.gateway_reply << params
    self.status = "#{params['payment_status']} (£#{params["mc_gross"]} via PayPal"
    self.save
  end
    
  def self.new_from_paypal_params(params)
     basket = Basket.find(params['custom'])
     order = Order.create(
      :user_id => (basket.user ? basket.user.id : basket.last_user.id),
      :user_email => (basket.user ? basket.user.email : basket.last_user.email),
      :delivery_subtotal => basket.delivery_subtotal,
      :discount_subtotal => basket.discount_subtotal,
      :products_subtotal => basket.products_subtotal,
      :total => basket.total,
      :delivery_summary => basket.delivery_summary,
      :delivery_first_names => basket.delivery_first_names,
      :delivery_surname => basket.delivery_surname,
      :delivery_address_1 => basket.delivery_address_1,
      :delivery_address_2 => basket.delivery_address_2,
      :delivery_city => basket.delivery_city,
      :delivery_county => basket.delivery_county,
      :delivery_postcode => basket.delivery_postcode,
      :delivery_country => basket.delivery_country,
      :billing_first_names => basket.billing_first_names,
      :billing_surname => basket.billing_surname,
      :billing_address_1 => basket.billing_address_1,
      :billing_address_2 => basket.billing_address_2,
      :billing_city => basket.billing_city,
      :billing_county => basket.billing_county,
      :billing_postcode => basket.billing_postcode,
      :billing_country => basket.billing_country,
      :gift_wrap => basket.gift_wrap,
      :gift_wrap_subtotal => basket.gift_wrap_subtotal,
      :gift_wrap_message => basket.gift_wrap_message,
      :status => "#{params['payment_status']} (£#{params["mc_gross"]} via PayPal)",
      :gateway_reply => [params],
      :transaction_code => params['txn_id']
    )
    # make the order items
    order.paypal_params_to_order_items(params)
    Mailer.deliver_order_invoice_to_admin(order)
    Mailer.deliver_order_invoice_to_customer(order)
  end     
  
  def paypal_params_to_order_items(params)
    params.each_pair do |k,v|
      if k =~ /item_number/i && !v.blank?
        number = k.gsub(/item_number/i, '')
        OrderItem.create(:order_id => id, :variation_id => v.to_i, :amount => params["quantity#{number}"].to_i, :subtotal => params["mc_gross_#{number}"].to_f, :product_name => params["item_name#{number}"])
        if Variation.exists?(v.to_i)
          variation = Variation.find(v.to_i)
          variation.update_attribute(:stock, variation.stock - params["quantity#{number}"].to_i)
        end
      end
    end
  end
  
  def self.sample_hash
    {
    "tax"=>"0.00", 
    "payment_status"=>"Completed", 
    "address_name"=>"Nicholas Bolt", 
    "address_city"=>"Hull", 
    "mc_shipping"=>"0.00", 
    "receiver_email"=>"seller_1284561622_biz@eskimosoup.co.uk", 
    "address_zip"=>"HU5 3TX", 
    "business"=>"seller_1284561622_biz@eskimosoup.co.uk", 
    "address_country"=>"United Kingdom", 
    "receiver_id"=>"VRGBWQXUXZLHY", 
    "transaction_subject"=>"32", 
    "payment_gross"=>"", 
    "action"=>"paypal_reply", 
    "notify_version"=>"3.1", 
    "item_name1"=>"CPAP Strap Cushions/Covers - Light (Grey)", 
    "payment_fee"=>"", 
    "mc_gross_1"=>"13.00", 
    "mc_currency"=>"GBP", 
    "address_street"=>"6 Dundee Street\r\nChanterlands Avenue", 
    "address_country_code"=>"GB", 
    "mc_handling1"=>"0.00", 
    "verify_sign"=>"A7tLjB3XcvBDmVztUkU5ZVpoNtYmA59kpm9cqscqOBMihHMbrgZ0XkAP", 
    "txn_id"=>"2GP142717F666450R", 
    "item_name2"=>"CPAP HOSE LIFT + Travel Bag - Keeps Tubing Away + Stops Water", 
    "mc_gross_2"=>"20.00", 
    "mc_handling2"=>"0.00", 
    "mc_shipping1"=>"0.00", 
    "item_name3"=>"&pound;6.99", 
    "txn_type"=>"cart",
    "mc_gross_3"=>"6.99", 
    "test_ipn"=>"1", 
    "mc_gross"=>"39.99", 
    "address_status"=>"confirmed", 
    "payer_id"=>"8KYAPP8DM28X8", 
    "charset"=>"windows-1252", 
    "mc_handling"=>"0.00", 
    "mc_fee"=>"1.56", 
    "mc_handling3"=>"0.00", 
    "mc_shipping2"=>"0.00", 
    "last_name"=>"User", 
    "controller"=>"baskets", 
    "item_number1"=>"29",
    "custom"=>"32",
    "payer_status"=>"verified", 
    "num_cart_items"=>"3", 
    "mc_shipping3"=>"0.00", 
    "address_state"=>"", 
    "quantity1"=>"2",
    "protection_eligibility"=>"Eligible", 
    "item_number2"=>"30", 
    "payment_date"=>"02:30:32 May 16, 2011 PDT", 
    "payer_email"=>"buyer1_1284561652_per@eskimosoup.co.uk", 
    "quantity2"=>"1", 
    "residence_country"=>"GB", 
    "ipn_track_id"=>"ZjV21Mqcc51DaHTb.SHJDg", 
    "item_number3"=>"", 
    "first_name"=>"Test", 
    "payment_type"=>"instant", 
    "quantity3"=>"1"
    }
  end
        
end
