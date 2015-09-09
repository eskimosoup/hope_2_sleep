class ProductsController < ApplicationController

  before_filter :set_options

  def set_options
    @option_1 = params[:option_1] if !params[:option_1].blank?
    @option_2 = params[:option_2] if !params[:option_2].blank?
    @option_3 = params[:option_3] if !params[:option_3].blank?  
  end


  def index
    @search  = Product.position.active
    @products = @search.paginate(:page => params[:page], :per_page => 2000)
  end  

  def show
    @product = Product.find(params[:id])
    @option_1s = @product.option_1_options(@option_1)
    @option_2s = @product.option_2_options(@option_2, @option_1) if @option_1
    @option_3s = @product.option_3_options(@option_3, @option_1, @option_2) if @option_2
  end
  
  def reviews
    @product = Product.find(params[:id])
    @reviews = Review.active.product_id_equals(@product.id)
  end
  
  def get_option_2s
    @product = Product.find(params[:id])
    @option_2s = @product.option_2_options(@option_2, @option_1) if @option_1
    @option_2s_in_stock = @product.option_2s_in_stock(@option_1)
    render :update do |page|
      page[:option_2s_js].replace_html :partial => "option_2s_js"
      page[:option_3s_js].replace_html :partial => "option_3s_js"
    end
  end
  
  def get_option_3s
    @product = Product.find(params[:id])
    @option_3s = @product.option_3_options(@option_3, @option_1, @option_2) if @option_2
    @option_3s_in_stock = @product.option_3s_in_stock(@option_1, @option_2)
    render :update do |page|
      page[:option_3s_js].replace_html :partial => "option_3s_js"
    end
  end
  
end
