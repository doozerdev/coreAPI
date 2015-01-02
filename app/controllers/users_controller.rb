class UsersController < BaseApiController
  def update
    if @user.role == 'admin'
      user = User.where(:uid=>params[:uid]).first
      user.role = params[:role]
      user.save
      json = user.as_json
      json.delete('oauth_token')
      json.delete('id')
      json.delete('session_id')

      render json: json, status: 202
    else
      render nothing: true, status: 401
    end
  end
end
