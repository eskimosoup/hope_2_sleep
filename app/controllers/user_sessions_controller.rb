class UserSessionsController < ApplicationController

  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Successfully logged in."
      if session[:checkout] && session[:checkout].to_time > Time.now-(60*5)
        session.delete(:checkout)
        redirect_to set_user_baskets_path
      elsif session[:review] && session[:review].to_time > Time.now-(60*5)
        session.delete(:review)
        redirect_to new_review_path
      else
        redirect_to users_path  
      end
    else
      render :action => "new"
    end
  end
    
  def destroy  
    @user_session = UserSession.find  
    @user_session.destroy
    flash[:notice] = "Successfully logged out."  
    if session[:checkout] && session[:checkout].to_time > Time.now-(60*5)
      session.delete(:checkout)
      redirect_to set_user_baskets_path
    elsif session[:review] && session[:review].to_time > Time.now-(60*5)
        session.delete(:review)
        redirect_to new_review_path
    else
      redirect_to root_path  
    end
  end  

end
