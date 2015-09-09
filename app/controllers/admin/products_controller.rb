class Admin::ProductsController < Admin::AdminController

  handles_images_for Product

  def index
    @products = Product.unrecycled.position
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(params[:product])
    if @product.save
      flash[:notice] = "Successfully created product."
      if @product.variations.length < 1
        redirect_to admin_variations_path(:product_id => @product.id)
      elsif Product.image_changes?(params[:product])
        redirect_to :action => "index_images", :id => @product.id
      else
        redirect_to admin_products_path
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    params[:product][:associated_product_ids] ||= []
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      flash[:notice] = "Successfully updated product."
      if @product.variations.length < 1
        redirect_to admin_variations_path(:product_id => @product.id)
      elsif Product.image_changes?(params[:product])
        redirect_to :action => "index_images", :id => @product.id
      else
        redirect_to admin_products_path
      end
    else
      render :action => 'edit'
    end
  end

  def order
    params[:draggable].each_with_index do |id, index|
      Product.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    flash[:notice] = "Successfully destroyed product."
    redirect_to admin_products_path
  end
end
