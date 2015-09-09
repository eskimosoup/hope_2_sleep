class WebController < ApplicationController

  def index
    redirect_to url_for(PageNode.name_like("home").first.path) if PageNode.name_like("home").first
	end

  def site_down

  end
    
  def site_search
    if params[:search]
      results = Search.site(params[:search])
      @results = results.paginate(:page => params[:page], :per_page => 10)
    else
      @results = []
    end
  end
  
  def site_map
    @roots = PageNode.active.roots
    @roots += PageNode.active.navigation.select{|x| x.parent && !x.parent.display_in_navigation? }
    @roots = @roots.sort_by{|x| x.name}
  end
  
  def contact_us
  	@page_node = PageNode.contact_us
  end
  
  def deliver_contact_us
		if params[:email].blank? && params[:tel].blank?
			flash[:error] = "Please enter either an email or telephone number so that we can get back to you."
			redirect_to :controller => "web", :action => "contact_us", :name => params[:name], :email => params[:email], :tel => params[:tel], :enquiry => params[:enquiry]
		else
			Mailer.deliver_contact_us(params[:name], params[:email], params[:tel], params[:enquiry])
			flash[:notice] = "Your enquiry has been sent."
			redirect_to :controller => "web", :action => "thank_you"
		end
  end
  
  def check
    raise params.to_yaml
  end
  
end
