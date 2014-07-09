class MembersController < ApplicationController
  #skip_before_action :authenticate_admin!, only: [:public_new, :create]
  
  def index
    if params[:search]
      @members = Member.search(params[:search])
    else
      @members = Member.includes(:educations).all.select(:id, :first_name, :infix, :last_name, :phone_number, :email, :student_id)
    end
  end

  def show
    @member = Member.find(params[:id])
  end
  
  def new
    @member = Member.new
    @member.educations.build( :id => '-1' )
  end
  
  def create
    @member = Member.new(member_post_params)   
    
    if @member.save
      redirect_to @member
    else
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
    
      redirect_to @member
    else
      render 'edit'
    end
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
                                   educations_attributes: [ :id, :name_id, :start_date, :end_date, :_destroy ])
  end
end
