class Admin::OrdersController < Admin::AdminController
  def invoice
    @order = Order.find(params[:id])
    render :layout => false
  end

  def index
    params[:search] ||= {}
    params[:search][:order] ||= "descend_by_online_invoice_number"
    @search = Order.unrecycled.search(params[:search])
    @orders = @search.paginate(:page => params[:page], :per_page => 50)
    if Order.unrecycled.sort_by{|x| x.created_at}.first
      date_1 = Order.unrecycled.sort_by{|x| x.created_at}.first.created_at.to_date
      date_2 = Order.unrecycled.sort_by{|x| x.created_at}.last.created_at.to_date
    else
      date_1 = Date.today
      date_2 = Date.today
    end
    if date_1 != date_2 
      @dates = [["All Months", nil]]
      @dates += (date_1..date_2).collect{|x| ["#{Date::MONTHNAMES[x.month]} #{x.year}", "#{x.year}-#{x.month}"] }.uniq
    end
    @total = 0
    for order in @search
      @total += order.total
    end
  end  

  def new
    @order = Order.new
  end  

  def create
    @order = Order.new(params[:order])
    if @order.save
      flash[:notice] = "Successfully created order."
      redirect_to admin_orders_path
    else
      render :action => 'new'
    end
  end  

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    if @order.update_attributes(params[:order])
      flash[:notice] = "Successfully updated order."
      redirect_to admin_orders_path
    else
      render :action => 'edit'
    end
  end  

  def order
    params[:draggable].each_with_index do |id, index|
      Order.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end  

  def cancel
    @order = Order.find(params[:id])
    @order.update_attribute(:status, "cancelled")
    @order.restore_stock
    Mailer.deliver_order_cancelled_to_customer(@order)
    flash[:notice] = "Successfully cancelled order."
    redirect_to edit_admin_order_path(@order)
  end
  
  def ship
    @order = Order.find(params[:id])
    @order.update_attribute(:status, "shipped")
    Mailer.deliver_order_shipped_to_customer(@order)
    flash[:notice] = "Successfully shipped order."
    redirect_to edit_admin_order_path(@order)
  end
  
  def cheque_paid
    @order = Order.find(params[:id])
    @order.update_attribute(:status, "Paid via Cheque")
    flash[:notice] = "Successfully marked order as paid."
    redirect_to edit_admin_order_path(@order)
  end
  
  
end
