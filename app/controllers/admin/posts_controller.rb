#:nodoc:
class Admin::PostsController < ApplicationController
  def index
    @pagination, @posts = pagination_posts
    @post = Post.new author: current_user.credentials
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post
    else
      @pagination, @posts = pagination_posts
      render 'index'
    end
  end

  def show
    @pagination, @posts = pagination_posts
    @post = Post.find_by_id params[:id]
    render 'index'
  end

  def update
    @post = Post.find_by_id params[:id]
    @post.update(post_params)
    @pagination, @posts = pagination_posts
    render 'index'
  end

  def destroy
    Post.destroy(params[:id])
    redirect_to :posts
  end

  private

  def pagination_posts
    @posts_array = Post.pinned + Post.unpinned.order(:published_at)
    return pagy_array(@posts_array, items: 10)
  end

  def post_params
    params.require(:post).permit(
      :id,
      :author_id,
      :author_type,
      :status,
      :pinned,
      :tags,
      :published_at,
      :title,
      :content
    )
  end
end
