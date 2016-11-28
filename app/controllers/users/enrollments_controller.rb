class Users::EnrollmentsController < ApplicationController
  skip_before_action :authenticate_admin!, only: [ :index ]

  def index
    @activities = Activity.where(
      '(end_date IS NULL AND start_date >= ?) OR end_date >= ?',
        Date.today, Date.today
      ).order(:start_date)
  end

  def delete
    @activity = Activity.find(params[:id])
    @enrollment = Participant.find_by(
        member_id: current_user.credentials_id,
        activity_id: @activity.id)
    @enrollment.destroy
  end

  def create
    @activity = Activity.find(params[:id])
    @new_enrollment = Participant.new(member_id: current_user.credentials_id, activity_id: @activity.id,
                                      price: @activity.price)
    @new_enrollment.save
  end
end
