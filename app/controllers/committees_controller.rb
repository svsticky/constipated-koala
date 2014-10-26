class CommitteesController < ApplicationController
  respond_to :json

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


  def createMember
    @committee = Committee.find(params[:committee])
    @committeeMember = CommitteeMember.new( :member => Member.find(params[:member]), :committee => @committee )

    if @committeeMember.save
      respond_with @committeeMember, :location => committees_url
    else
      respond_with @committeeMember.errors.full_messages
    end      
  end

  def updateMember
    @committeeMember = CommitteeMember.find(params[:id])

    @committeeMember.update_attributes(:function => params[:functionName])
    if @committeeMember.save
      render :status => :ok, :json => @committeeMember
    else
      respond_with @committeeMember.errors.full_messages
    end
  end

  def destroyMember
    respond_with CommitteeMember.destroy(params[:id])
  end


  private
  def committee_post_params
    params.require(:committee).permit( :name,
                                       :comments)
  end
end
