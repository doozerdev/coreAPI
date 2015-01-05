class BaseApiController < ApplicationController
  before_filter :authenticate_user_from_token!

  private
  def authenticate_user_from_token!
    if !request.headers["HTTP_SESSION_ID"]
      render nothing: true, status: :unauthorized
    else
      @user = User.where(:session_id => request.headers.fetch("HTTP_SESSION_ID")).first
      unless @user
        render nothing: true, status: :unauthorized 
      end
    end
  end

end
