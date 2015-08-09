class Admins::MembersController < ApplicationController
  respond_to :json, only: [:find]

  def index
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0

    @page = @offset / @limit

    if params[:search]
      @members = Member.search(params[:search], params[:all] ||= false)
      @pages = (@members.size / @limit.to_f).ceil

      @members = @members[@offset,@limit]

      @search = params[:search]
      @all = params[:all] || false

      if @members.size == 1 && @offset == 0 && @limit > 1
        redirect_to @members.first
      end

    else
      @members = Member.includes(:educations).all.select(:id, :first_name, :infix, :last_name, :phone_number, :email, :student_id).order(:last_name, :first_name).limit(@limit).offset(@offset)
      @pages = (Member.count / @limit.to_f).ceil
    end
  end

  def find
    @members = Member.select(:id, :first_name, :infix, :last_name, :student_id).search(params[:search], params[:all] ||= false)
    respond_with @members
  end

  def show
    @member = Member.find(params[:id])

    @activities = @member.activities.study_year( params['year'] ).order( start_date: :desc ).joins( :participants ).distinct
    @years = (@member.join_date.year .. Date.start_studyyear( Date.current().year ).year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse

    #pagination for mongoose transactions
    @limit = params[:limit] ? params[:limit].to_i : 10
    @offset = params[:offset] ? params[:offset].to_i : 0
    @transactions = CheckoutTransaction.where( :checkout_balance => CheckoutBalance.find_by_member_id(params[:id])).order(created_at: :desc).limit(@limit).offset(@offset)

    @page = @offset / @limit
    @pages = (CheckoutTransaction.where( :checkout_balance => CheckoutBalance.find_by_member_id(params[:id])).count / @limit.to_f).ceil
  end

  def new
    @member = Member.new
    @member.educations.build( :id => '-1' )
  end

  def create
    @member = Member.new(member_post_params)

    if @member.save
      impressionist(@member, 'nieuwe lid')
      redirect_to @member
    else
      if @member.educations.length < 1
        @member.educations.build( :id => '-1' )
      end

      render 'new'
    end
  end

  def edit
    @member = Member.includes(:educations).includes(:tags).find(params[:id])

     if @member.educations.length < 1
       @member.educations.build( :id => '-1' )
     end
  end

  def update
    @member = Member.find(params[:id])

    if @member.update(member_post_params)
      impressionist(@member, 'lid bewerkt')
      redirect_to @member
    else
      render 'edit'
    end
  end

	def destroy
		@member = Member.find(params[:id])
    impressionist(@member, "#{@member.first_name} #{@member.infix} #{@member.last_name} verwijderd")

		@member.destroy
		redirect_to members_path
	end

  private
  def member_post_params
    params.require(:member).permit(:first_name,
                                   :infix,
                                   :last_name,
                                   :address,
                                   :house_number,
                                   :postal_code,
                                   :city,
                                   :phone_number,
                                   :email,
                                   :gender,
                                   :student_id,
                                   :birth_date,
                                   :join_date,
                                   :comments,
                                   :tags_names => [],
                                   educations_attributes: [ :id, :study_id, :status, :start_date, :end_date, :_destroy ])
  end
end
