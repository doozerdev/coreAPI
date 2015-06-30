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
    solutionsList = ItemSolutionMap.where(:solutionId => params[:id])
    itemsList = solutionsList.collect{|s| Item.where(:id=>s.itemId).first}
    render json: {items: itemsList}, :status => :ok
  end

  def addLink
    ism = ItemSolutionMap.new(params.permit(:itemId))
    ism.solutionId = params[:id]
    ism.dateAssociated = DateTime.now

    if ism.save
      render json: ism, status: :created
    else
      render nothing: true, status: :bad_request
    end
  end

  def removeLink
    ItemSolutionMap.where(:itemId=>params[:itemId],
                          :solutionId=>params[:id]).destroy_all

    render nothing: true, status: 200
  end

  #DELETE /item/:id
  #DeleteItem
  def destroy
    Solution.destroy(params[:id])
    render json: {deleted: true}, status: 200
  end

  private
  def check_authZ
    unless @user.role == 'admin'
      render nothing: true, status: :unauthorized
    end
  end

end
