class Admins::SettingsController < ApplicationController
  respond_to :json, only: [:mail, :destroy]

  def index
    @settings = UserConfiguration.all

    @studies = Study.all

    @advert = Advertisement.new
    @advertisements = Advertisement.all
  end

  def advertisement
    @advert = Advertisement.new(advertisement_post_params)

    if @advert.save
      redirect_to settings_path
    else
      @settings = UserConfiguration.all

      @advertisements = Advertisement.all
      render 'index'
    end
  end

  def destroy_advertisement
    if params[:id].blank?
      render :status => :bad_request, :json => 'no id given'
    end

    advert = Advertisement.find(params[:id])
    advert.destroy

    render :status => :no_content, :json => ''
  end

  def mailings
    @activities = Activity.take(1)
    @recipients = @activities.first.participants.order('members.first_name', 'members.last_name').joins(:member).select(:id, :member_id, :first_name, :email)
  end

  # Send a mail to all debtors
  def mail
    puts params[:recipients]

    @activities = Activity.where( :id => params[:id] )
    # participants_information(recipients, activities, sender, subject, html, text)
    render :json => Mailgun.participants_information(params[:recipients], @activities, current_user.credentials.sender, params[:subject], params[:html], nil).deliver_later
  end

  private
  def advertisement_post_params
    params.require(:advertisement).permit(  :name,
                                            :poster)
  end
end
