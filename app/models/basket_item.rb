class BasketItem < ActiveRecord::Base

  belongs_to :basket
  belongs_to :variation
  
  def subtotal
    ret = 0
    ret += price_per_product * amount 
    ret 
  end
  
  def price_per_product
    ret = 0
    ret += variation.product.price
    ret
  end
  
  def weight
    ret = 0
    ret += variation.product.weight * amount 
    ret 
  end
  
  def convert_to_order_item(order)
    OrderItem.create(
      :order_id => order.id,
      :variation_id => self.variation.id,
      :amount => self.amount,
      :subtotal => self.subtotal,
      :product_name => self.variation.product_name_variation
    )
    variation.update_attribute(:stock, variation.stock - amount)
  end
  
  def orderable?
    amount > variation.stock ? false : true
  end
  
  def product_name_variation
    variation.product_name_variation
  end
  
    
end
