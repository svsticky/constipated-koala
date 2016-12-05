class Users::EnrollmentsController < ApplicationController
  skip_before_action :authenticate_admin!, only: [ :index, :create, :delete ]

  def index
    @activities = Activity.where(
      '(end_date IS NULL AND start_date >= ?) OR end_date >= ?',
        Date.today, Date.today
      ).where(is_enrollable: true).order(:start_date)
    current_member = Member.find(current_user.credentials_id)
    @enrollments = current_member.activities.where(id: @activities.ids)
  end

  def delete
    @activity = Activity.find(params[:id])

    if !@activity.is_enrollable?
      render :status => :locked, :json => {
        message: I18n.t(:not_unenrollable, scope: 'activerecord.errors.models.activity')
      }
      return
    end

    @enrollment = Participant.find_by(
        member_id: current_user.credentials_id,
        activity_id: @activity.id)
    @enrollment.destroy

    head :ok
  end

  def create
    @activity = Activity.find(params[:id])

    if !@activity.is_enrollable?
      render :status => :locked, :json => {
        message: I18n.t(:not_enrollable, scope: 'activerecord.errors.models.activity')
      }
      return
    end
    if !@activity.participant_limit.nil? && @activity.participants.count >= @activity.participant_limit
      render :status => :payload_too_large, :json => {
        message: I18n.t(:participant_limit_reached, scope: 'activerecord.errors.models.activity')
      }
      return
    else
      @new_enrollment = Participant.new(member_id: current_user.credentials_id, activity_id: @activity.id,
                                        price: @activity.price)
      @new_enrollment.save
      head :ok
    end
  end
end
