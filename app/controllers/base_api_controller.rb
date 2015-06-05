class BaseApiController < ApplicationController
  before_filter :authenticate_user_from_token!

  private
  def authenticate_user_from_token!
    if !request.headers["HTTP_SESSIONID"]
      render nothing: true, status: :unauthorized
    else
      @user = User.where(:session_id => request.headers["HTTP_SESSIONID"]).first

      if @user
        if @user.expires_at < DateTime.now
          @user.session_id = nil
          @user.save
          @user = nil
        else
          @user.expires_at = DateTime.now + 24.hours
          @user.save
        end
      else
        render nothing: true, status: :unauthorized
      end
    end
  end

end
