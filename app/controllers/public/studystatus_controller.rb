#:nodoc:
class Public::StudystatusController < MembersController
  skip_before_action :authenticate_user!, only: [:index, :create, :confirm]
  skip_before_action :authenticate_admin!, only: [:index, :create, :confirm]

  def edit; end

  def update; end
end
