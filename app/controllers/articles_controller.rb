class ArticlesController < ApplicationController
  
  def index
  	params[:page] ||= 1
  	if params[:tag]
  	  @title = "News: #{params[:tag]}"
      @search = Article.active.tagged_with(params[:tag].to_s, :on => "tags")
    elsif params[:year] && params[:month]
      @title = "News: #{Date::MONTHNAMES[params[:month].to_i]} #{params[:year]}"
      @search = Article.active.year(params[:year]).month(params[:month])
    elsif params[:year]
      @title = "News: #{params[:year]}"
    	@search = Article.active.year(params[:year])
    else
      @title = "News"
      @search = Article.active
    end
    @articles = @search.paginate(:page => params[:page], :per_page => 20)
  end  

  def show
    @article = Article.find(params[:id])
    unless @article.active?
      redirect_to articles_path
    end
  end
  
end
