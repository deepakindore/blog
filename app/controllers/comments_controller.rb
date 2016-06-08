class CommentsController < ApplicationController

  before_action :get_article_id, only: [:new, :create, :show, :update, :destroy, :edit, :approve]
  before_action :current_comment_id, only: [:edit, :update, :destroy, :show, :approve]
  before_action :yet_not_approved, only: :approve
  before_action :show_modifiable, only: [:update, :edit]

  def new
  end

  def create
    respond_to do |format|
      if @current_article.update(validate_params)
        format.html { redirect_to article_path(@current_article) }
        format.js {}
      else
        format.html { render 'article/show' }
      end
    end
  end

  def show
  end

  def edit
  end

  def update
    if @comment.update(validate_params)
      redirect_to article_path(@current_article)
    else
      render 'edit'
    end
  end

  def destroy
    @comment.destroy
    redirect_to article_path(@current_article)
  end

  def approve
    respond_to do |format|
      @comment.update_attribute(:approved, true)
      format.html { redirect_to article_path(@current_article) }
      format.js {}
    end
  end

  private

  def get_article_id
    @current_article = Article.find(params[:article_id])
  end

  def validate_params
    params['article']["comments_attributes"].each{|k, v| v.merge!(user_id: current_user.id)}
    params.require(:article).permit(comments_attributes: [:id, :commenter, :body, :user_id])
  end

  def current_comment_id
    @comment = Comment.find(params[:id])
  end

  def yet_not_approved
    redirect_to article_path(@current_article) unless @comment.is_article_owner?(current_user)
  end

  def show_modifiable
    redirect_to article_path(@current_article) unless @comment.can_modify?(current_user)
  end

end
