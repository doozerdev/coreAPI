class BaseApiController < ApplicationController
  before_filter :authenticate_user_from_token!

  private
  def authenticate_user_from_token!
    if !params['session_id']
      render nothing: true, status: :unauthorized
      puts 'no session_id'
    else
      @user = nil
      @user = User.where(:session_id=>params['session_id']).first
      unless @user
        render nothing: true, status: :unauthorized 
        puts 'not authorized'
      end
    end
  end

end
