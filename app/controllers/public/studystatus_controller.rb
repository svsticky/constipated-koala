#:nodoc:
class Public::StudystatusController < PublicController
  def edit
    # adding intent so that you're not on the wrong page.
    @token = Token.find_by!(token: params[:token], intent: :studystatus)
    @member = @token.object
  end

  def update
    @token = Token.find_by!(token: params[:token], intent: :studystatus)
    @member = @token.object

    if @member.update(member_post_params)
      @token.destroy

      impressionist @member
      redirect_to public_path
    else
      render 'edit'
    end
  end

  private

  def member_post_params
    params.require(:member).permit(educations_attributes: [:id, :study_id, :status])
  end
end
