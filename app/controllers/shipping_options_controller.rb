class ShippingOptionsController < ApplicationController
  
  def index
    @shipping_options = ShippingOption.find_by_country_and_weight(params[:country], params[:weight])
    render :update do |page|
      page[:shipping_options].replace_html :partial => "shipping_options/index"
    end
  end
  
end
