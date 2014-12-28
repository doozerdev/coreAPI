class ItemsController < BaseApiController

  before_action :check_authZ, only: [:show, :children, :update, :destroy]

  #POST /item/index
  #AllLists
  def index
    render json: {items: Item.where(:user_id=>@user.uid, :parent => nil)}, status: 200
  end

  #POST /item/create
  #AddItem
  def create
    item = Item.new
    if params[:title]
      item.title = params[:title]
      item.user_id = @user.uid
      if params[:parent] and !params[:parent].empty?
        item.parent = params[:parent]
      end
      if params[:duedate] and !params[:duedate].empty?
        item.duedate = DateTime.httpdate(params[:duedate])
      end
      if params[:order] and !params[:order].empty?
        item.order = params[:order].to_i
      end

      item.done = params[:done].to_bool if params[:done]
      item.archive = params[:archive].to_bool if params[:archive]

      item.notes = params[:notes]

      item.save
      render json: item, status: 201
    else
      render json: {error: 'title is required'}, status: 400
    end
  end

  #POST /item/:id
  #GetItem
  def show
    puts params[:id]
    render json: Item.where(:id => params[:id]).first, status: 200
  end

  #POST /item/:id/children
  #GetChildren
  def children
    render json: {items: Item.where(:user_id=>@user.uid,
                                    :parent=>params['id'])}, status: 200
  end

  #PUT /item/:id
  #UpdateItem
  def update
    item = Item.update(params[:id], params.permit(:title, :duedate, :order,
                                                  :done, :archive, :notes))
    if params[:parent] and !params[:parent].empty?
      item.parent = params[:parent]
      item.save
    else
      item.parent = nil
      item.save
    end
    render json: item, status: 202
  end

  #DELETE /item/:id
  #DeleteItem
  def destroy
    count = 0

    children = Item.where(:user_id=>@user.uid,
                          :parent=>params['id'])
    children.each do |child|
      Item.destroy(child.id)
      count = count + 1 
    end

    Item.destroy(params[:id])
    count = count + 1

    render json: {delete_item_count: count}, status: 200
  end

  private
  def check_authZ
    if params[:id] and !params[:id].empty?
      item = Item.where(:id => params[:id]).first
      unless item and item.user_id == @user.uid
        render nothing: true, status: :unauthorized     
      end
    else
      render nothing: true, status: :unauthorized 
    end
  end
end
