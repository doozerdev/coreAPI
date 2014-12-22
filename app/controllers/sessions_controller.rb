class SessionsController < ApplicationController
  #Login
  def create
    user = User.from_token(params[:oauth_token])
    if user
      render json: {'session_id'=> user.session_id}, status: 201
    else
      render nothing: true, status: 401
    end
  end

  def destroy
    user = User.where(:session_id => params[:session_id]).first
    user.session_id = nil
    user.expires_at = DateTime.now
    user.save
    user = nil
    render nothing: true, status: 200
  end
end
