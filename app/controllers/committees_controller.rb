class CommitteesController < ApplicationController

  def index
    @committees = Committee.all
    @committee = Committee.new
  end

  def show
    @committee = Committee.find(params[:id])
  end

  def new
    @committee = Committee.new
  end

  def create
    @committee = Committee.new(committee_post_params)

    if @committee.save
      redirect_to @committee
    else
      @committees = Committee.all
      render 'index'
    end
  end

  def edit
    @committee = Committee.find(params[:id])
  end

  def update
    @committee = Committee.find(params[:id])

    if @committee.update(committee_post_params)
      redirect_to @committee
    else
      render 'edit'
      return
    end
  end

  def destroy
    @committee = Committee.find(params[:id])
    @committee.destroy

    redirect_to committees_path
  end

  private
  def committee_post_params
    params.require(:committee).permit( :name,
                                       :comments)
  end
end
