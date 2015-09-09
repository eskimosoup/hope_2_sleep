class BasketsController < ApplicationController

  include ActionView::Helpers::NumberHelper

  before_filter :initialize_basket
  
  after_filter :reset_shipping, :only => [:add_to, :increase, :decrease, :remove]
  
  def reset_shipping
    @current_basket.update_attributes(:shipping_option_id => nil, :delivery_summary => nil)
  end
  
  protect_from_forgery :except => [:paypal_reply, :google_reply, :paymentsense_reply]

  def initialize_basket
    Basket.tidy
    if session[:basket_id] && Basket.exists?(session[:basket_id])
      @current_basket = Basket.find(session[:basket_id])
    else
      @current_basket = Basket.create!
      session[:basket_id] = @current_basket.id
    end
    if current_user 
      @current_basket.update_attribute(:user_id, current_user.id)
    end
  end

  def index
  end
  
  def add_to
    product = Product.find(params[:product_id])
    variation = Variation.product_id_equals(params[:product_id])
    variation = variation.option_1_equals(params[:option_1]) if !params[:option_1].blank?
    variation = variation.option_2_equals(params[:option_2]) if !params[:option_2].blank?
    variation = variation.option_3_equals(params[:option_3]) if !params[:option_3].blank?
    if variation.length > 1
      flash[:error] = "Please select all of the options before adding a product to your basket."
      redirect_to product_path(product, :option_1 => params[:option_1], :option_2 => params[:option_2], :option_3 => params[:option_3], :anchor => "form")
      return
    else
      variation = variation.first
    end
    if variation.stock > 0
      same_variation = @current_basket.basket_items.select{|x| x.variation_id == variation.id}.first
      if same_variation
        same_variation.update_attribute(:amount, same_variation.amount + 1)
        flash[:notice] = "Amount increased"
      else
        BasketItem.create(:basket_id => @current_basket.id, :variation_id => variation.id)
        flash[:notice] = "Added to basket"
      end
    else 
      flash[:error] = "Sorry, this item is out of stock"
    end
    redirect_to basket_path
  end
  
  def increase
    basket_item = BasketItem.find(params[:basket_item_id])
    new_amount = basket_item.amount + 1
    if new_amount > basket_item.variation.stock
      flash[:error] = "Sorry, we do not have enough stock to increase the amount"  
    else
      basket_item.update_attribute(:amount, new_amount)
      flash[:notice] = "Amount increased"
    end
    redirect_to basket_path
  end
  
  def decrease
    basket_item = BasketItem.find(params[:basket_item_id])
    new_amount = basket_item.amount - 1
    if new_amount == 0
      basket_item.destroy
      flash[:notice] = "Product removed from basket"
    else
      basket_item.update_attribute(:amount, new_amount)
      flash[:notice] = "Amount decreased"
    end
    redirect_to basket_path
  end
  
  def remove
    basket_item = BasketItem.find(params[:basket_item_id])
    if basket_item.basket == @current_basket
      basket_item.destroy
      flash[:notice] = "Product removed from basket"
    else
      flash[:error] = "You do not have persmission to alter this Product"
    end
    redirect_to basket_path
  end
  
  def begin_checkout
    if @current_basket.delivery_ready?
      redirect_to :action => "delivery"    
    else
      redirect_to :action => "user"
    end
  end
  
  def delivery
    unless @current_basket.delivery_ready?
      redirect_to :action => "user"
      return    
    end
    @shipping_options = ShippingOption.find_by_country_and_weight(@current_basket.delivery_country, @current_basket.weight)  
    @addresses = @current_basket.user.addresses
  end
  
  def delivery_shipping
    @shipping_options = ShippingOption.find_by_country_and_weight(@current_basket.delivery_country, @current_basket.weight)  
  end
  
  def set_delivery
    if @current_basket.update_attributes(params[:basket])
      # have a look at the address and see if it is one which the user has not used before
      Address.create_from_basket_billing(@current_basket) if @current_basket.new_billing_address?(params[:basket])
      Address.create_from_basket_delivery(@current_basket) if @current_basket.new_delivery_address?(params[:basket])
      if @current_basket.shipping_option && @current_basket.delivery_country && @current_basket.shipping_option.region_include?(@current_basket.delivery_country)
        @current_basket.update_attribute(:delivery_summary, @current_basket.shipping_option.summary)
        redirect_to :action => "payment"
      else
        redirect_to :action => "delivery_shipping"      
      end
    else
      @shipping_options = ShippingOption.find_by_country_and_weight(@current_basket.delivery_country, @current_basket.weight)  
      @addresses = @current_basket.user.addresses
      # if for any reason the addresses can't be set give it a default value.
      @addresses ||= []
      render :action => "delivery"
    end
  end
  
  def change_billing_address
    if Address.exists?(params[:address_id])
      address = Address.find(params[:address_id])
    else
      address = Address.new    
    end
    render :update do |page|
      page[:basket_billing_first_names].value = address.first_names
      page[:basket_billing_surname].value = address.surname
      page[:basket_billing_address_1].value = address.address_1
      page[:basket_billing_address_2].value = address.address_2
      page[:basket_billing_city].value = address.city
      page[:basket_billing_postcode].value = address.postcode            
      page[:basket_billing_country].value = address.country
    end
  end
  
  def change_delivery_address
    if Address.exists?(params[:address_id])
      address = Address.find(params[:address_id])
    else
      address = Address.new    
    end
    render :update do |page|
      page[:basket_delivery_first_names].value = address.first_names
      page[:basket_delivery_surname].value = address.surname
      page[:basket_delivery_address_1].value = address.address_1
      page[:basket_delivery_address_2].value = address.address_2
      page[:basket_delivery_city].value = address.city
      page[:basket_delivery_postcode].value = address.postcode            
      page[:basket_delivery_country].value = address.country
      page << "fireEvent(document.getElementById('basket_delivery_country'), 'change');"
    end
  end
  
  def set_gift_wrap
    if @current_basket.update_attributes(params[:basket])
      redirect_to :action => "payment"
    else
      render :action => "gift_wrap"
    end
  end

  def set_promotional_code 
    promo_code = PromoCode.find_by_code(params[:promo_code])
    if promo_code.nil?
      flash[:error] = "Could not find a promotion with the code you entered."
    elsif promo_code.active?
      @current_basket.update_attribute(:promo_code_id, promo_code.id)     
      flash[:notice] = "Code accepted!"
    elsif promo_code.start_date > Date.today
      flash[:error] = "Sorry, this code is not active yet."
    elsif promo_code.end_date < Date.today
      flash[:error] = "Sorry, this code has expired."
    end
    render :action => "index"
  end
  
  def remove_promotional_code
    @current_basket.update_attribute(:promo_code_id, nil)
    flash[:notice] = "Promotional code removed."
    redirect_to :action => "index"
  end
  
  def user
    if current_user
      @current_basket.update_attribute(:user_id, current_user.id)
    end
    session[:checkout] = Time.now
    @user_session = UserSession.new
    @user = User.new
  end
  
  def set_user
    if current_user
      redirect_to :action => "delivery"
    else
      redirect_to :action => "user"
    end  
  end
  
  def switch_user
    session[:checkout] = Time.now
    redirect_to logout_path
  end
  
  def payment
    unless @current_basket.payment_ready?
      redirect_to :action => "index"    
    end
        
    # PAYPAL URL
    #business = 'seller_1284561622_biz@eskimosoup.co.uk' # demo
    business = 'hope2sleep@hope2sleep.co.uk' # live
    
    return_url = url_for(:controller => "users", :action => "index", :only_path => false)
    notify_url = url_for(:controller => "baskets", :action => "paypal_reply", :only_path => false)
  	
  	values = {
      :business => business,
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :notify_url => notify_url,
      :currency_code => 'GBP',
      :no_shipping => 0,
      :address1 => @current_basket.billing_address_1,
      :address2 => @current_basket.billing_address_2,
      :city => @current_basket.billing_city,
      :country => @current_basket.billing_country,
      :email => @current_basket.user.email,
      :first_name => @current_basket.billing_first_names,
      :last_name => @current_basket.billing_surname,
      :zip => @current_basket.billing_postcode, 
      :custom => @current_basket.id
    }
    
    # add all items to basket
    count = 0
    @current_basket.basket_items.each do |basket_item|
      count += 1
      values.merge!({
        "amount_#{count}" => sprintf('%.2f', basket_item.price_per_product),
        "item_name_#{count}" => basket_item.product_name_variation,
        "item_number_#{count}" => basket_item.variation.id,
        "quantity_#{count}" => basket_item.amount
      })
    end
    
    # calculate the total discount and apply it to the cart
    if @current_basket.discount_subtotal > 0
      values = values.merge(:discount_amount_cart => @current_basket.discount_subtotal)
    end

    # add gift wrap    
    if @current_basket.gift_wrap? 
      count += 1
      values.merge!({
        "amount_#{count}" => sprintf('%.2f', @current_basket.gift_wrap_subtotal),
        "item_name_#{count}" => "Gift Wrap"
      })
    end
    
    # add delivery
    if @current_basket.delivery_subtotal > 0 
      count += 1
      values.merge!({
        "amount_#{count}" => sprintf('%.2f', @current_basket.delivery_subtotal),
        "item_name_#{count}" => "Delivery"
      })
    end
    
    #@paypal_url = "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query # DEMO
    @paypal_url = "https://www.paypal.com/cgi-bin/webscr?" + values.to_query # LIVE4976000000003436 

    
    logger.info "PayPal Link Values Generated"
    logger.info values.to_yaml
  end
  
  def paypal_reply
    logger.info "PayPal IPN"
    
    # ignore refunds
    if params['payment_status'] == 'Refunded'
      logger.info params.to_yaml
      render :nothing => true
      return
    end
   
    # check for existing order (by transaction code)
    existing_order = Order.find(:first, :conditions => {:transaction_code => params['txn_id']})
    if existing_order
      # if existing order
      existing_order.update_from_paypal_params(params)
    else
      # if new order
      Order.new_from_paypal_params(params)
    end
    
    # get rid of the basket in question
    Basket.find(params['custom']).destroy if Basket.exists?(params['custom'])
    render :nothing => true
  end
  
  def paymentsense_reply
    logger.info "Paymentsense POST"
    # if the transaction was a success
    if params['StatusCode'] == '0' && Basket.exists?(params['OrderID'].to_i)
      basket = Basket.find(params['OrderID'].to_i)
      basket.convert_to_order("Successful Paymentsense Payment ( #{ number_to_currency((params['Amount'].to_f / 100), :unit => '£') })", params)
      redirect_to users_path
    else
      logger.info "Paymentsense Error"
    end
  end
  
  def google_reply
    logger.info "GOOGLE REPLY"
    logger.info params.to_yaml
    render :nothing => true
  end
  
  def cheque
    @page_node = PageNode.find_by_name("Paying By Cheque")
  end
  
  def confirm_cheque
    unless params[:terms_and_conditions] == "1"
      @page_node = PageNode.find_by_name("Paying By Cheque")
      flash[:error] = "You must accept the terms and conditions before your order can be placed."
      render :action => "cheque"
      flash[:error] = nil
    else
      if current_basket && current_basket.payment_ready?
        @order = current_basket.convert_to_order("pending payment via cheque", {:time => Time.now})      
      end
      @page_node = PageNode.find_by_name("Confirmed Cheque Payment")
    end
  end

end
