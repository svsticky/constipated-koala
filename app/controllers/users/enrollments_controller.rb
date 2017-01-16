class Users::EnrollmentsController < ApplicationController
  skip_before_action :authenticate_admin!, only: [ :index, :create, :delete, :show ]

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
        message: I18n.t(:not_unenrollable, scope: 'activerecord.errors.models.activity', activity: @activity.name),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    @enrollment = Participant.find_by(
        member_id: current_user.credentials_id,
        activity_id: @activity.id)
    @enrollment.destroy

    render :status => 200, :json => {
        message: I18n.t(:not_enrolled, scope: 'activerecord.errors.models.activity', activity: @activity.name),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
    }
  end

  def create
    @activity = Activity.find(params[:id])

    if !@activity.is_enrollable?
      render :status => :locked, :json => {
        message: I18n.t(:not_enrollable, scope: 'activerecord.errors.models.activity'),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    @member = Member.find(current_user.credentials_id)
    if @activity.is_alcoholic? && @member.is_underage?
      render :status => 451, :json => { # Unavailable for legal reasons
        message: I18n.t(:participant_underage, scope: 'activerecord.errors.models.activity', activity: @activity.name),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    if !@activity.participant_limit.nil? && @activity.participants.count >= @activity.participant_limit
      @new_enrollment = Participant.new(member_id: @member.id, activity_id: @activity.id,
                                        price: @activity.price, reservist: true)
      @new_enrollment.save

      render :status => :accepted, :json => {
        message: I18n.t(:participant_limit_reached, scope: 'activerecord.errors.models.activity', activity: @activity.name),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    else
      @new_enrollment = Participant.new(member_id: @member.id, activity_id: @activity.id,
                                        price: @activity.price)
      @new_enrollment.save
      render :status => 200, :json => {
          message: I18n.t(:enrolled, scope: 'activerecord.errors.models.activity', activity: @activity.name),
          participant_limit: @activity.participant_limit,
          participant_count: @activity.participants.count
      }
    end
  end

  def show
    @activity = Activity.find(params[:id])
  end
end
