class AdminDevise::UnlocksController < Devise::UnlocksController

  private

  def after_unlock_path_for(resource)
    super
    impressionist(resource)
  end

end
