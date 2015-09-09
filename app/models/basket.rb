class Basket < ActiveRecord::Base

  MerchantId = 'wwwhop-6151265' # LIVE
  #MerchantId = 'wwwhop-7744004'# TEST
  CurrencyCode = '826'
  
  has_many :basket_items, :dependent => :destroy
  belongs_to :promo_code
  belongs_to :user
  belongs_to :shipping_option
  belongs_to :last_user, :class_name => "User"
  
  named_scope :basket_type, lambda {|x| {} }
  named_scope :ascend_by_ready, lambda {|x| {} }
  named_scope :descend_by_ready, lambda {|x| {} }  
  named_scope :ascend_by_basket_items_length, lambda {|x| {} }
  named_scope :descend_by_basket_items_length, lambda {|x| {} }
  
  validates_presence_of :delivery_first_names, :delivery_surname, 
    :delivery_address_1, :delivery_city, :delivery_country, 
    :billing_first_names, :billing_surname, :billing_address_1, 
    :billing_city, :billing_country, :on => :update
    
  before_save :set_last_user

  def contents
    ret = ""
    ret += basket_items.length.to_s
    if basket_items.length > 0
      ret += " ("
      summary = basket_items.collect{|x| x.variation.product.name if x.variation && x.variation.product}.to_sentence
      ret += summary.length > 50 ? "#{summary[0..50]}..." : summary
      ret += ")"
    end
    ret
  end
    
  def products_subtotal
    ret = 0
    for basket_item in basket_items
      ret += basket_item.subtotal
    end
    ret 
  end
  
  def delivery_subtotal
    ret = 0
    ret += shipping_option.price if shipping_option
    ret  
  end
  
  def self.safe_gift_wrap_price
    price = SiteSetting.like("Gift Wrap Price").first
    if price && price.value?
      return price.value.to_f
    else
      4.95
    end
  end
  
  def gift_wrap_subtotal
    ret = 0
    ret += Basket.safe_gift_wrap_price if gift_wrap?
    ret
  end
  
  def discount_subtotal
    ret = 0
    if promo_code
      if promo_code.promo_code_type == "percentage_off_basket"
        ret += ( products_subtotal * (promo_code.percentage_off.to_f / 100.to_f).to_f )
      elsif promo_code.promo_code_type == "percentage_off_products"
        for basket_item in basket_items
          if promo_code.products.include?(basket_item.product)        
            ret += (basket_item.subtotal * (promo_code.percentage_off.to_f / 100.to_f).to_f)
          end
        end
      elsif promo_code.promo_code_type == "amount_off_basket"
        ret += promo_code.amount_off
      elsif promo_code.promo_code_type == "amount_off_products"
        for basket_item in basket_items
          if promo_code.products.include?(basket_item.product)        
            ret += promo_code.amount_off
          end
        end
      elsif promo_code.promo_code_type == "free_shipping"
        if promo_code.shipping_options.include?(shipping_option)
          ret += shipping_option.price        
        end
      end
    end
    ret
  end
  
  def weight
    ret = 0
    for basket_item in basket_items
      ret += basket_item.weight
    end
    ret
  end
  
  def total
    ret = 0
    ret += products_subtotal
    ret += delivery_subtotal if !delivery_subtotal.blank?
    ret += gift_wrap_subtotal
    ret -= discount_subtotal
    ret
  end
  
  def total_pence
    (total * 100).to_i
  end
  
  def new_billing_address?(params)
    Address.user_id_equals(self.user.id).first_names_like(params[:billing_first_names]).surname_like(params[:billing_surname]).address_1_like(params[:billing_address_1]).address_2_like(params[:billing_address_2]).city_like(params[:billing_city]).county_like(params[:billing_county]).postcode_like(params[:billing_postcode]).country_like(params[:billing_country]).length > 0 ? false : true
  end
  
  def new_delivery_address?(params)
    Address.user_id_equals(self.user.id).first_names_like(params[:delivery_first_names]).surname_like(params[:delivery_surname]).address_1_like(params[:delivery_address_1]).address_2_like(params[:delivery_address_2]).city_like(params[:delivery_city]).county_like(params[:delivery_county]).postcode_like(params[:delivery_postcode]).country_like(params[:delivery_country]).length > 0 ? false : true
  end
  
  def empty?
    basket_items.length > 0 ? false : true
  end
  
  def orderable?
    for basket_item in basket_items
      return false if !basket_item.orderable?
    end
    return true
  end
  
  def user_ready?
    return false if empty?
    true
  end
  
  def user_done?
    return false if empty?
    return false if user == nil
    true
  end
  
  def delivery_ready?
    user_done?
  end
  
  def delivery_done?
    return false if !user_done?
    return false if !self.delivery_first_names?
    return false if !self.delivery_surname?
    return false if !self.delivery_address_1?
    return false if !self.delivery_city?
    return false if !self.delivery_country?
    return false if !self.billing_first_names?
    return false if !self.billing_surname?
    return false if !self.billing_address_1?
    return false if !self.billing_city?
    return false if !self.billing_country?
    #return false if !self.delivery_summary?
    return false if self.delivery_subtotal.nil?
    return false if self.shipping_option_id.nil?
    true
  end
  
  def gift_ready?
    delivery_done?
  end
  
  def gift_done?
    return false if !delivery_done?
    #return false if gift_wrap.nil?
    true
  end
  
  def payment_ready?
    gift_done?
  end
    
  def convert_to_order(status, gateway_reply, skip_email=false)
    order = Order.create(
      :user_id => (self.user ? self.user.id : self.last_user.id),
      :user_email => (self.user ? self.user.email : self.last_user.email),
      :delivery_subtotal => self.delivery_subtotal,
      :discount_subtotal => self.discount_subtotal,
      :products_subtotal => self.products_subtotal,
      :total => self.total,
      :delivery_summary => self.delivery_summary,
      :delivery_first_names => self.delivery_first_names,
      :delivery_surname => self.delivery_surname,
      :delivery_address_1 => self.delivery_address_1,
      :delivery_address_2 => self.delivery_address_2,
      :delivery_city => self.delivery_city,
      :delivery_county => self.delivery_county,
      :delivery_postcode => self.delivery_postcode,
      :delivery_country => self.delivery_country,
      :billing_first_names => self.billing_first_names,
      :billing_surname => self.billing_surname,
      :billing_address_1 => self.billing_address_1,
      :billing_address_2 => self.billing_address_2,
      :billing_city => self.billing_city,
      :billing_county => self.billing_county,
      :billing_postcode => self.billing_postcode,
      :billing_country => self.billing_country,
      :gift_wrap => self.gift_wrap,
      :gift_wrap_subtotal => self.gift_wrap_subtotal,
      :gift_wrap_message => self.gift_wrap_message,
      :status => status,
      :gateway_reply => gateway_reply
    )
  
    # check that there are no problems with the order (items gone out of stock
    # while the parson was paying - etc) and email the admin if this is the case
    begin
      if !self.orderable?
        bad_items = []
        for basket_item in basket_items 
          bad_items << basket_item if !basket_item.orderable?
        end
        unless skip_email
          Mailer.deliver_order_problem_to_admin(order, bad_items)
        end
      end

      for basket_item in basket_items
        basket_item.convert_to_order_item(order)
      end
      
      unless skip_email
        Mailer.deliver_order_invoice_to_admin(order)
        Mailer.deliver_order_invoice_to_customer(order)
      end
    rescue
      order.update_attributes(:notes => "There was a problem emailing this customer with a confirmation.  You may wish to inform the customer that their order has been taken.")    
    end
    
    self.destroy
    order
  end
  
  def self.tidy
    # destroy all 30 day old baskets
    Basket.find(:all, :conditions => ["created_at < ? AND keep = false", (Date.today-30)]) do |basket|  
      basket.destroy
    end
    # destroy all 7 day old baskets unless they are in the ready for payment mode
    Basket.find(:all, :conditions => ["created_at < ? AND keep = false", (Date.today-7)]) do |basket|
      basket.destroy unless basket.payment_ready?
    end
  end
  
  def paymentsense_hash_digest(time, callback_url)
    h = [
          ['PreSharedKey', 'Bb1tWfKQ2NgU4GrLaVvyd/yPTeBFPpc8GkZyCM8bqPsK2SPS4rngz36Z0T8nTuikVy9Lplz+/PDoec4='], 
          ['MerchantID', MerchantId],
          ['Password', 'Sc00byd002'],
          ['Amount', total_pence.to_s],
          ['CurrencyCode', CurrencyCode],
          ['OrderID', self.id.to_s],
          ['TransactionType', 'SALE'],
          ['TransactionDateTime', time],
          ['CallbackURL', callback_url.to_s],
          ['OrderDescription', ''],
          ['CustomerName', ''],
          ['Address1', ''],
          ['Address2', ''],
          ['Address3', ''],
          ['Address4', ''],
          ['City', ''],
          ['State', ''],
          ['PostCode', ''],
          ['CountryCode', ''],
          ['CV2Mandatory', 'false'],
          ['Address1Mandatory', 'false'],
          ['CityMandatory', 'false'],
          ['PostCodeMandatory', 'false'],
          ['StateMandatory', 'false'],
          ['CountryMandatory', 'false'],
          ['ResultDeliveryMethod', 'POST'],
          ['ServerResultURL', callback_url.to_s],
          ['PaymentFormDisplaysResult', 'true'],
          ['ServerResultURLCookieVariables', ''],
          ['ServerResultURLFormVariables', ''],
          ['ServerResultURLQueryStringVariables', '']
    ]
    
    h = h.map{|pair| pair[0] + "=" + pair[1]}.join("&")
    
    logger.info "VALUES"
    logger.info h.to_s

    require 'digest/sha1' 
    hash_digest = Digest::SHA1.hexdigest(h.to_s)
    
    logger.info "HASH"
    logger.info hash_digest
    
    return hash_digest
  end

  def set_last_user
    unless self.user.nil?
      self.last_user = self.user
    end
  end
end
