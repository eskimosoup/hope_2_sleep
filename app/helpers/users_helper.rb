module UsersHelper

  def current_user_session  
    return @current_user_session if defined?(@current_user_session)  
    @current_user_session = UserSession.find  
  end  
    
  def current_user  
    @current_user = current_user_session && current_user_session.record  
  end  
  
  def validate_user
    unless current_user
      flash[:error] = "You must login to view this content"
      redirect_to user_login_path
      return
    end
  end
  
  def validate_no_user
    if current_user
      flash[:error] = "You must not be logged in to view this content"
      redirect_to root_url
      return
    end
  end

end
