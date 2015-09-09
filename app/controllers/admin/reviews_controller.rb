class Admin::ReviewsController < Admin::AdminController

  def index
    # set the default ordering
    params[:search] ||= {}
  	params[:search][:order] ||= "ascend_by_checked"
    @search = Review.unrecycled.search(params[:search])
    @reviews = @search.paginate(:page => params[:page], :per_page => 50)
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new(params[:review])
    if @review.save
      flash[:notice] = "Successfully created review."
      redirect_to admin_reviews_path
    else
      render :action => 'new'
    end
  end

  def edit
    @review = Review.find(params[:id])
  end  

  def update
    @review = Review.find(params[:id])
    if @review.update_attributes(params[:review])
      flash[:notice] = "Successfully updated review."
      redirect_to admin_reviews_path
    else
      render :action => 'edit'
    end
  end  

  def order
    params[:draggable].each_with_index do |id, index|
      Review.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end  

  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    flash[:notice] = "Successfully destroyed review."
    redirect_to admin_reviews_path
  end
  
  def update_name
    @user_name = User.find(params[:user_id]).name if User.exists?(params[:user_id])
    render :update do |page|
      page["name_field"].replace_html :partial => "admin/reviews/name_field"
    end
  end
end
