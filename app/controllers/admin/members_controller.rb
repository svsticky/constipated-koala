class Admin::MembersController < ApplicationController
  # replaced with calls in each of the methods
  # impressionist :actions => [ :create, :update ]
  respond_to :json, only: [:search]

  def index
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0

    @page = @offset / @limit

    # If a search query is send, change the limit and offset accordingly. The param all is whether the query should also look into alumni
    if params[:search]
      @results = Member.search( params[:search].clone )

      @pages = (@results.size / @limit.to_f).ceil
      @members = @results[@offset,@limit]

      @members = Member.none if @members.nil?
      @search = params[:search]

      if @members.size == 1 && @offset == 0 && @limit > 1
        redirect_to @members.first
      end

    else
      @members = Member.includes(:educations).where( :id => ( Education.select( :member_id ).where( 'status = 0' ).map{ |education| education.member_id} + Tag.select( :member_id ).where( :name => Tag.active_by_tag ).map{ | tag | tag.member_id } )).select(:id, :first_name, :infix, :last_name, :phone_number, :email, :student_id).order(:last_name, :first_name).limit(@limit).offset(@offset)
      @pages = (Member.count / @limit.to_f).ceil
    end
  end

  # As defined above this is an json call only
  def search
    @members = Member.select(:id, :first_name, :infix, :last_name, :student_id).search(params[:search])
    respond_with @members
  end

  def show
    @member = Member.find(params[:id])

    # Show all activities from the given year. And make a list of years starting from the member's join_date until the last activity
    @activities = @member
      .activities
      .study_year( params['year'] )
      .order( start_date: :desc )
      .joins( :participants ).distinct
      .where( "participants.reservist = ?", false)
    @years = ( @member.join_date.study_year .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse

    # Pagination for checkout transactions, limit is the number of results per page and offset is the number of the first record
    @limit = params[:limit] ? params[:limit].to_i : 10
    @offset = params[:offset] ? params[:offset].to_i : 0
    @transactions = CheckoutTransaction.where( :checkout_balance => CheckoutBalance.find_by_member_id(params[:id])).order(created_at: :desc).limit(@limit).offset(@offset)
  end

  def new
    @member = Member.new

    # Construct a education so that there is always one visible to fill in
    @member.educations.build( :id => '-1' )
  end

  def create
    @member = Member.new(member_post_params)

    if @member.save

      # impressionist is the logging system
      impressionist(@member, 'nieuwe lid')
      redirect_to @member
    else

      # If the member hasn't filled in a study, again show an empty field
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
      impressionist @member
      redirect_to @member
    else
      render 'edit'
    end
  end

	def destroy
		member = Member.find(params[:id])
    impressionist(member, member.name)

    member.destroy
		redirect_to members_path
	end

  def payment_whatsapp
    @member = Member.find(params[:member_id])
    render layout: false, content_type: "text/plain"
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
