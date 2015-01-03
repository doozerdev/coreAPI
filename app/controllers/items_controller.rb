class ItemsController < BaseApiController

  before_action :check_authZ, only: [:show, :children, :update, :destroy]

  #GET /item/index
  #AllLists
  def index
    render json: {items: Item.where(:user_id=>@user.uid, :parent => nil)}, status: 200
  end

  #POST /item/create
  #AddItem
  def create
    if params[:title]
      item = Item.new(params.permit(:title, :parent, :duedate, :order,
                                    :done, :archive, :notes))

      if params[:parent] and !params[:parent].empty? and !check_authZ_item(params[:parent])
        render json: {error: 'parent not found'}, status: 404
      else
        item.user_id = @user.uid
        item.save
        render json: item, status: 201
      end
    else
      render json: {error: 'title is required'}, status: 400
    end
  end

  #GET /item/:id
  #GetItem
  def show
    render json: Item.where(:id => params[:id]).first, status: 200
  end

  #GET /item/:id/children
  #GetChildren
  def children
    render json: {items: Item.where(:user_id=>@user.uid,
                                    :parent=>params['id'])}, status: 200
  end

  #PUT /item/:id
  #UpdateItem
  def update
    item = Item.update(params[:id], params.permit(:title, :parent, :duedate, :order,
                                                  :done, :archive, :notes))
    if params[:parent] and !check_authZ_item(params[:parent])
      render json: {error: 'parent not found'}, status: 404
    else
      item.save
      render json: item, status: 202
    end
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

  def search
    if @user.role == 'admin'
      items = Item.all(:title => /#{Regexp.escape(params['term'])}/)
      render json: {count: items.count, items: items}, status: 200
    else
      items = Item.where(:user_id=>@user.uid, 
        :title => /#{Regexp.escape(params['term'])}/)
      render json: {count: items.count, items: items}, status: 200
    end
  end

  private
  def check_authZ
    if params[:id] and !params[:id].empty?
      unless check_authZ_item(params[:id])
        render json: {error: 'item not found'}, status: 404
      end
    else
      render json: {error: 'item not found'}, status: 404
    end
  end

  def check_authZ_item(item_id)
    item = Item.where(:id => item_id).first
    unless item and item.user_id == @user.uid
      return false
    else
      return true
    end
  end
end
