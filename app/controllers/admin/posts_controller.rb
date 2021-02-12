#:nodoc:
class Admin::PostsController < ApplicationController
  def index
    # TODO: add filters, for pinned draft etc
    @pagination, @posts = pagy(Post.all.order(:published_at), items: 10)
    @post = Post.new author: current_user.credentials
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post
    else
      @pagination, @posts = pagy(Post.all.order(:published_at), items: 10)
      render 'index'
    end
  end

  def show
    @pagination, @posts = pagy(Post.all.order(:published_at), items: 10)
    @post = Post.find_by_id params[:id]
    render 'index'
  end

  def update
    @post = Post.find_by_id params[:id]
    @post.update(post_params)
    @pagination, @posts = pagy(Post.all.order(:published_at), items: 10)
    render 'index'
  end

  def destroy
    Post.destroy(params[:id])
    redirect_to :posts
  end

  private

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
