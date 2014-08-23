class MembersController < ApplicationController
  
  def index
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0
  
    @page = @offset / @limit
    @pagination = 5
  
    if params[:search]
      @members = Member.search(params[:search])
      @pages = Member.count / @limit
            
      if @members.size == 1
        redirect_to @members.first
      end
    else    
      @members = Member.includes(:educations).all.select(:id, :first_name, :infix, :last_name, :phone_number, :email, :student_id).order(:last_name, :first_name).limit(@limit).offset(@offset)
      @pages = Member.count / @limit
    end
  end

  def show
    @member = Member.find(params[:id])
    @activities = (@member.activities.joins(:participants).where(:participants => { :paid => false, :member => @member } ).distinct + @member.activities.order(start_date: :desc).limit(10)).uniq.sort_by(&:start_date).reverse
  end
  
  def new
    @member = Member.new
    @member.educations.build( :id => '-1' )
  end
  
  def create
    @member = Member.new(member_post_params)   
    
    if @member.save
      @current_user = current_admin
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
      
      
      #door de tags heen loopen
      Tag.list.each_with_index do | tag, i |
      
        #als een van het lijstje is ingevuld, tag aanmaken als die niet bestaat
        if member_post_params[:tags_name_ids].include?("#{tag.last}")
          
          if Tag.where(:member_id => @member.id, :name_id => i).blank?
            db = Tag.new(:member_id => @member.id, :name_id => i)
          #of touch om timestamps aan te passen
          else
            db = Tag.where(:member_id => @member.id, :name_id => i).first
            db.touch
          end
                  
          if db.valid?
            db.save
          else
            @member.errors.add(db.errors)
            render 'edit'
            return
          end
        else
          #anders verwijderen als er een bestaat
          db = @member.tags.where(:name_id => i).first
          
          if !db.nil?
            db.destroy
          end
        end
      end
      
      @current_user = current_admin
      impressionist(@member, 'lid bewerkt')
    
      redirect_to @member
    else
      render 'edit'
    end
  end
  
	def destroy
		@member = Member.find(params[:id])
		
    @current_user = current_admin
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
                                   :tags_name_ids => [],
                                   educations_attributes: [ :id, :study_id, :start_date, :end_date, :_destroy ])
  end
end
