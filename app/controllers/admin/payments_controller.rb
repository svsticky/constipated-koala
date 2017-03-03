class Admin::PaymentsController < ApplicationController
  impressionist :actions => [ :create, :update, :destroy ]

  def index
    @detailed = Activity.debtors.sort_by(&:start_date).reverse!
  end
end
