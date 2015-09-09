class UsersController < ApplicationController

  before_filter :validate_user, :only => [:index, :edit, :update]
  
  def index
  
  end

  def new
    @user = User.new
  end  

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Successfully registered."
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
      render :action => 'new'
    end
  end  

  def edit  
    @user = current_user  
  end  
    
  def update  
    @user = current_user
    if @user.update_attributes(params[:user])  
      flash[:notice] = "Successfully updated profile."  
      redirect_to root_url
    else  
      render :action => 'edit'  
    end  
  end   
  
end
