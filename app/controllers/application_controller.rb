# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include UsersHelper
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  before_filter :check_for_site_maintenance
  before_filter :check_basket
  
  def check_basket
    @current_basket = Basket.find(session[:basket_id]) if session[:basket_id] && Basket.exists?(session[:basket_id])
    if @current_basket
      if current_user
        @current_basket.update_attribute(:user_id, current_user.id)
      else
        @current_basket.update_attribute(:user_id, nil)
      end
    end
  end
  
  def check_for_site_maintenance
    if SiteSetting.find_by_name("Site Down For Maintenance").value == "true"
      unless current_administrator  
        unless params[:controller] == "web" && params[:action] == "site_down"
          redirect_to :controller => "web", :action => "site_down"
        end
      end
    end
    current_administrator
  end
  
	helper_method :current_administrator
	
	helper_method :current_basket  
	
	private
	
	def current_basket
    @current_basket
  end

  def current_administrator_session
    return @current_administrator_session if defined?(@current_administrator_session)
    @current_administrator_session = AdministratorSession.find
  end
  
  def current_administrator
    return @current_administrator if defined?(@current_administrator)
    @current_administrator = current_administrator_session && current_administrator_session.record
  end
  
  protected  

		def log_error(exception) 
    	super(exception)
	    begin
	    
	    	if ENV['RAILS_ENV']=='production'
  	    	
  	    	if (exception.class == ActionController::RoutingError && SiteSetting.like("Report Routing Errors").first && SiteSetting.like("Report Routing Errors").first.value == "true") || (exception.class != ActionController::RoutingError && SiteSetting.like("Report Errors").first && SiteSetting.like("Report Errors").first.value == "true")
  	    	  
    	    	  AdminMailer.deliver_exception_snapshot(
		            exception, 
		            clean_backtrace(exception), 
		            session.instance_variable_get("@data"), 
		            params, 
		            request.env)
		        
	        end
		            
		    end
	    rescue => e
	      logger.error(e)
	    end
  	end

end
