class ReviewsController < ApplicationController

  before_filter :validate_user, :only => [:new, :create]
  
  def desire_new
    session[:review] = Time.now
    session[:review_product] = params[:product_id]
    redirect_to new_review_path
  end

  def new
    unless session[:review_product]
      flash[:error] = "Cannot create review without product information."
      redirect_to :back
    end
    @review = Review.new(:product_id => session[:review_product], :user_id => current_user.id)
  end

  def create
    @review = Review.new(params[:review])
    if @review.save
      flash[:notice] = "Thanks for the feedback, we will check your review and post it as soon as possible."
      redirect_to @review.product
    else
      render :action => 'new'
    end
  end
  
end
