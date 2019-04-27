#:nodoc:
class Public::GdprController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :create, :confirm]
  skip_before_action :authenticate_admin!, only: [:index, :create, :confirm]

  def edit; end

  def update; end
end
