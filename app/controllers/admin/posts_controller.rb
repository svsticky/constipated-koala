#:nodoc:
class Admin::PostsController < ApplicationController  
  def index
    # TODO: add filters, for pinned draft etc
    @pagination, @posts = pagy(Post.all)
    @post = Post.new author: current_user.credentials
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post
    else

      @posts = Post.all
      render 'index'
    end
  end

  def show
    @pagination, @posts = pagy(Post.all)
    @post = Post.find_by_id params[:id]
    render 'index'
  end

  def update
    @post = Post.find_by_id params[:id]
    
    if @post.update(post_params)
      if post_params["status"] == "scheduled"
        @time_until_post = DateTime.parse(post_params[:published_at])
        Post.perform_at(@time_until_post, params[:id])
      end

      redirect_to @post
    else
      @pagination, @posts = pagy(Post.all)
      render 'index'
    end
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
      :content
    )
  end
end
