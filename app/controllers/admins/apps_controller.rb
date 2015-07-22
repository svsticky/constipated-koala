class Admins::AppsController < ApplicationController

  def ideal
    @transactions = IdealTransaction.find_by_date( params['date'] || Date.yesterday )
    @summary = IdealTransaction.summary( @transactions )
  end
end
