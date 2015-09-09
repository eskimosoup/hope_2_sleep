class Mailer < ActionMailer::Base
	
	add_template_helper ApplicationHelper
	add_template_helper NumberHelper

	def contact_us(name, email, tel, enquiry)
    @subject           = "Contact Us Form Completed - #{SiteSetting.like("Site Name").first.value}"
    @from              = email
    @recipients        = SiteSetting.like("Email").first.value
    @body[:enquiry]    = enquiry
    @body[:name]       = name
    @body[:email]      = email
    @body[:tel]        = tel
    content_type "text/html"  
  end
  
  def order_problem_to_admin(order, bad_items)
    @subject           = "There was a problem with a customer order (#{order.online_invoice_number})"
    @from              = SiteSetting.like("Order Email").first.value
    @recipients        = SiteSetting.like("Order Email").first.value
    @body[:order]      = order
    @body[:bad_items]  = bad_items
    content_type "text/html"
  end
  
  def order_invoice_to_admin(order)
    @subject           = "New Hope 2 Sleep Order (#{order.online_invoice_number})"
    @from              = SiteSetting.like("Order Email").first.value
    @recipients        = SiteSetting.like("Order Email").first.value
    @body[:order]      = order
    content_type "text/html"
  end
  
  def order_invoice_to_customer(order)
    @subject           = "Your Hope 2 Sleep Order (#{order.online_invoice_number})"
    @from              = SiteSetting.like("Order Email").first.value
    @recipients        = order.user.email
    @body[:order]      = order
    content_type "text/html"
  end
  
  def order_cancelled_to_customer(order)
    @subject           = "Your Hope 2 Sleep Order (#{order.online_invoice_number}) has been Cancelled"
    @from              = SiteSetting.like("Order Email").first.value
    @recipients        = order.user.email
    @body[:order]      = order
    content_type "text/html"
  end
  
  def order_shipped_to_customer(order)
    @subject           = "Your Hope 2 Sleep Order (#{order.online_invoice_number}) has been Shipped"
    @from              = SiteSetting.like("Order Email").first.value
    @recipients        = order.user.email
    @body[:order]      = order
    content_type "text/html"
  end
  
end
