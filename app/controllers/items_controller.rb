class ItemsController < BaseApiController

  before_action :check_authZ, only: [:show, :children, :update, :destroy]

  def lists
    puts 'lists'
    items = Item.where(:user_id=>@user.uid, :archive => [false, nil], :parent=>['', nil] )

    render json: {items: items}, status: 200
  end

  #GET /items/
  #AllLists
  def index
    if(params[:last_sync])
      items = Item.where(:user_id=>@user.uid, :archive => [false, nil], :updated_at => params[:last_sync] )
    else
      items = Item.where(:user_id=>@user.uid, :archive => [false, nil] )
    end
    
    render json: {items: items}, status: 200
  end

  #POST /item/create
  #AddItem
  def create
    if params[:title] and !params[:title].empty?
      item = Item.new(params.permit(:title, :parent, :duedate, :order,
                                    :done, :archive, :notes))

      if params[:parent] and !params[:parent].empty? and !check_authZ_item(params[:parent])
        render json: {error: 'parent not found'}, status: 404
      else
        item.parent = '' unless params[:parent]

        item.user_id = @user.uid
        item.save
        render json: item, status: :created
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
    children = Item.where(:user_id=>@user.uid, :parent=>params['id'], :archive => [false, nil]).order(:order)
    render json: {items: children}, status: 200
  end

  #PUT /item/:id
  #UpdateItem
  def update
    item = Item.update(params[:id], params.permit(:title, :parent, :duedate, :order,
                                                  :done, :archive, :notes))
    if (params[:parent] and !params[:parent].empty?) and !check_authZ_item(params[:parent])
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
    items = nil
    start_time = Time.now
    if @user.role == 'admin'
      items = Item.all(:title => /#{Regexp.escape(params['term'])}/)
    else
      items = Item.where(:user_id=>@user.uid, 
        :title => /#{Regexp.escape(params['term'])}/)
    end
    end_time = Time.now
    render json: {request_time: "#{((end_time-start_time)*1000).round(2)} ms", count: items.count, items: items}, status: 200
  end

  def most_common_words
    if @user.role == 'admin'
      start_time = Time.now
      words = Hash.new
      Item.each do |i|
        i.title.split.each do |w|
          if words.has_key?(w)
            words[w] = words[w]+1
          else
            words[w] = 1
          end
        end
      end
      end_time = Time.now
      render json: {request_time: "#{((end_time-start_time)*1000).round(2)} ms", words: words.sort_by{|word, count| count}.reverse.first(50)}, status: 200
    else
      render nothing: true, status: :unauthorized 
    end
  end

  def solutions
    if @user.role == 'admin' or Item.find(params[:id]).user_id == @user.id
      render json: {solutions: ItemSolutionMap.where(:item_id => params[:id])}, :status => :ok
    else
      render nothing: true, status: :unauthorized
    end
  end

  def addLink
    ism = new ItemSolutionMap(params.permit(:solutionId))

    ism.date_associated = DateTime.now
    if ism.save
      render json: ism, status: :created
    else
      render nothing: true, status: :bad_request
    end
  end

  def removeLink
    ItemSolutionMap.where(:item_id=>params[:itemId],
                          :solution_id=>params[:solutionId]).destroy_all
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
    unless item and (item.user_id == @user.uid or @user.role == 'admin')
      return false
    else
      return true
    end
  end
end
