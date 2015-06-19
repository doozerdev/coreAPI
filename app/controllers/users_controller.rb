class UsersController < BaseApiController
  before_action :check_admin, only: [:updateAdmin, :index, :destroy]
  before_action :check_user, only: [:show, :update]

  def index
    render json: User.all, status: :ok
  end

  def show
    render json: User.where(:uid => params[:id]).first, status :ok
  end

  def destroy
    if User.destroy(:params[:id])
      render json: {deleted: true}, status: 200
  end

  def update
    user = User.update(params[:id],
                        params.permit(:email, :first_name, :last_name
                          :gender, :timezone))
    user.save
    render json: user, status: 202
  end

  def updateAdmin
    user = User.where(:id=>params[:id]).first
    user.role = params[:role]
    user.save

    render json: json, status: :accepted
  end

  private
  def check_admin
    unless @user.role == 'admin'
      render nothing: true, status: :unauthorized
    end
  end

  def check_user
    unless @user.id == params[:id] or @user.role == 'admin'
      render nothing: true, status: :unauthorized
    end
  end
end
