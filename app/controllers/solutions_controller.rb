class SolutionsController < BaseApiController
  before_action :check_authZ

  def index
    render json: Solution.all, status: 200
  end

  def create
    if params[:title] and !params[:title].empty?
      solution = Solution.new(params.permit(:title, :source, :description,
                                            :price, :address, :phone_number,
                                            :open_hours, :link, :tags, :expire_date,
                                            :img_link, :notes, :archive))
      solution.save
      render json: solution, status: :created
    else
      render json: {error: 'title is required'}, status: 400
    end
  end

  def show
    render json: Solution.where(:id => params[:id]).first, status: 200
  end

  def update
    solution = Solution.update(params[:id],
                               params.permit(:title, :source, :description,
                               :price, :address, :phone_number,
                               :open_hours, :link, :tags, :expire_date,
                               :img_link, :notes, :archive))
    solution.save
    render json: solution, status: 202
  end

  def items
    solutionsList = ItemSolutionMap.where(:solution_id => params[:id])
    itemsList = solutionsList.collect{|s| Item.where(:id=>s.item_id).first}
    render json: {items: itemsList}, :status => :ok
  end

  def addLink
    ism = ItemSolutionMap.new(params.permit(:item_id))
    ism.solution_id = params[:id]
    ism.date_associated = DateTime.now.utc

    if ism.save
      render json: ism, status: :created
    else
      render nothing: true, status: :bad_request
    end
  end

  def removeLink
    ItemSolutionMap.where(:item_id=>params[:item_id],
                          :solution_id=>params[:id]).destroy_all

    render nothing: true, status: 200
  end

  def like
    save_action(1)
    render nothing: true, status: :created
  end

  def dislike
    save_action(2)
    render nothing: true, status: :created
  end

  def click
    save_action(3)
    render nothing: true, status: :created
  end

  def view
    save_action(4)
    render nothing: true, status: :created
  end


  #DELETE /item/:id
  #DeleteItem
  def destroy
    Solution.destroy(params[:id])
    render json: {deleted: true}, status: 200
  end

  private
  def save_action (id)
    solution_activity = SolutionActivity.new(:userId=>@user.id,
                         :solution_id=>params[:id],
                         :item_id=>params[:item_id],
                         :action_id =>id)
    solution_activity.save
  end

  def check_authZ
    unless @user.role == 'admin'
      render nothing: true, status: :unauthorized
    end
  end

end
