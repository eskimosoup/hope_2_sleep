class Admin::VariationsController < Admin::AdminController
  def index
    params[:search] ||= {:smart_order => true}
    @product = Product.find(params[:product_id])
    @search = Variation.unrecycled.product_id_equals(@product.id).search(params[:search])
    @variations = @search.paginate(:page => params[:page], :per_page => 50)
  end  
  
  def update_stock
    if params[:stock]
      params[:stock].each_pair do |k,v|
        if !Variation.find(k.to_i).update_attributes(:stock => v)
          flash[:error] = "Invalid stock level encountered. Stock update halted at invalid entry (#{v})."
          redirect_to admin_variations_path(:product_id => params[:product_id])
          return
        end    
      end
      flash[:notice] = "Stock updated."
    else
      flash[:error] = "No stock to update."
    end
    redirect_to admin_variations_path(:product_id => params[:product_id])
  end

  def new
    @variation = Variation.new(:product_id => params[:product_id])
    @product = Product.find(params[:product_id])
    @similar_variations = @product.variations
  end  

  def create
    @variation = Variation.new(params[:variation])
    @product = Product.find(params[:variation][:product_id])
    @similar_variations = @product.variations
    if @variation.save
      flash[:notice] = "Successfully created variation."
      redirect_to admin_variations_path(:product_id => @variation.product_id)
    else
      render :action => 'new'
    end
  end  

  def edit
    @variation = Variation.find(params[:id])
    @product = @variation.product
    @similar_variations = @product.variations
  end  

  def update
    @variation = Variation.find(params[:id])
    @product = @variation.product
    @similar_variations = @product.variations
    if @variation.update_attributes(params[:variation])
      flash[:notice] = "Successfully updated variation."
      redirect_to admin_variations_path(:product_id => @variation.product_id)
    else
      render :action => 'edit'
    end
  end  

  def order
    params[:draggable].each_with_index do |id, index|
      Variation.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end  

  def destroy
    @variation = Variation.find(params[:id])
    variation_product_id = @variation.product_id
    @variation.destroy
    flash[:notice] = "Successfully destroyed variation."
    redirect_to admin_variations_path(:product_id => variation_product_id)
  end
end
