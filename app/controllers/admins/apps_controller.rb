class Admins::AppsController < ApplicationController

  def ideal
    @transactions = IdealTransaction.all
  end
  
  def studystatus
    
  end
  
  def studystatus_run
    require 'open3'
    
    Open3.popen3("/usr/local/bin/studystatus",
             "--username", params[:username],
             "--password", params[:password]) do |i, o, e, t|

      unless params[:student].nil?
        member = Member.find_by_student_id params[:student]
        i.puts params[:student]
        member.update_studies(o.gets)

        render :status => :ok, :json => "update #{params[:student]}"
        return
      end

      Member.all.each do |member|
        i.puts member.student_id
        member.update_studies(o.gets)
      end
  
      i.close
    end
    
    
    render :status => :ok, :json => 'update students'
  end
end
