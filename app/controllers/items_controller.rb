class ItemsController < BaseApiController
  before_action :check_authZ, only: [:show, :children, :update, :destroy, :archive, :solutions]

  before_action :check_admin, only: [:lists_for_user, :children_for_user, :most_common_words]

  def lists
    items = Item.where(user_id: @user.uid, archive: [false, nil], parent: ['', nil])

    render json: { items: items }, status: 200
  end

  def lists_for_user
    items = Item.where(user_id: params[:uid], archive: [false, nil], parent: ['', nil])

    render json: { items: items }, status: 200
  end

  # GET /items/
  # AllLists
  def index
    items = Item.where(user_id: @user.uid)
    if params[:last_sync]
      begin
        last_sync = DateTime.parse(params[:last_sync])
      rescue
        last_sync = DateTime.strptime(params[:last_sync], '%s')
      end

      items = items.select { |a| DateTime.parse(a.updated_at.to_s) > last_sync }
    end

    render json: { items: items }, status: 200
  end

  def create
    if params[:title] && !params[:title].empty?
      item = Item.new(params.permit(:title, :done, :archive, :parent, :order,
                                    :duedate, :notes, :solutions, :color, :type))

      if params[:parent] && !params[:parent].empty? && !check_authZ_item(params[:parent])
        render json: { error: 'parent not found' }, status: 404
      else
        item.parent = '' unless params[:parent]

        item.user_id = @user.uid
        item.save
        render json: item, status: :created
      end
    else
      render json: { error: 'title is required' }, status: 400
    end
  end

  def show
    render json: Item.where(id: params[:id]).first, status: 200
  end

  def children
    children = Item.where(user_id: @user.uid, parent: params['id'], archive: [false, nil]).order(:order)
    render json: { items: children }, status: 200
  end

  def children_for_user
    children = Item.where(user_id: params[:uid], parent: params['id'], archive: [false, nil]).order(:order)
    render json: { items: children }, status: 200
  end

  def update
    originalItem = Item.find(params[:id])
    item = Item.update(params[:id], params.permit(:title, :done, :archive, :parent,
                                                  :order, :duedate, :notes, :solutions,
                                                  :color, :type))

    if (!originalItem.done and item.done)
      item.date_completed = DateTime.now
    elsif (originalItem.done and !item.done)
      item.date_completed = nil
    end

    if (params[:parent] && !params[:parent].empty?) && !check_authZ_item(params[:parent])
      render json: { error: 'parent not found' }, status: 404
    else
      item.save
      render json: item, status: 202
    end
  end

  def archive
    count = 0

    children = Item.where(user_id: @user.uid,
                          parent: params['id'])
    children.each do |child|
      Item.update(child.id, archive: true)
      count += 1
    end

    Item.update(params['id'], archive: true)
    count += 1

    render json: { archive_item_count: count }, status: 200
  end

  # DELETE /item/:id
  # DeleteItem
  def destroy
    count = 0

    children = Item.where(user_id: @user.uid,
                          parent: params['id'])
    children.each do |child|
      Item.destroy(child.id)
      count += 1
    end

    Item.destroy(params[:id])
    count += 1

    render json: { delete_item_count: count }, status: 200
  end

  def most_common_words
    start_time = Time.now
    words = {}
    Item.each do |i|
      i.title.split.each do |w|
        if words.key?(w)
          words[w] = words[w] + 1
        else
          words[w] = 1
        end
      end
    end
    end_time = Time.now
    render json: { request_time: "#{((end_time - start_time) * 1000).round(2)} ms", words: words.sort_by { |_word, count| count }.reverse.first(50) }, status: 200
  end

  def solutions
    itemsList = ItemSolutionMap.where(item_id: params[:id])
    solutionsList = itemsList.collect { |i| Solution.where(id: i.solution_id).first }
    render json: { items: solutionsList }, status: :ok
  end

  def addLink

    ism = ItemSolutionMap.new

    ism.solution_id = params[:solution_id]
    ism.item_id = params[:item_id]
    ism.date_associated = DateTime.now.utc

    if ism.save
      render json: ism, status: :created
    else
      render nothing: true, status: :bad_request
    end
  end

  def removeLink
    ItemSolutionMap.where(item_id: params[:item_id],
                          solution_id: params[:solution_id]).destroy_all

    render nothing: true, status: 200
  end

  def search
    items = nil
    start_time = Time.now
    if @user.role == 'admin'
      items = Item.where(archive: [false, nil], title: /#{Regexp.escape(params['term'])}/i)
    else
      items = Item.where(user_id: @user.uid, title: /#{Regexp.escape(params['term'])}/i, archive: [false, nil])
    end
    end_time = Time.now
    render json: { request_time: "#{((end_time - start_time) * 1000).round(2)} ms", count: items.count, items: items }, status: 200
  end

  private

  def check_authZ
    if params[:id] && !params[:id].empty?
      unless check_authZ_item(params[:id])
        render json: { error: 'item not found' }, status: 404
      end
    else
      render json: { error: 'item not found' }, status: 404
    end
  end

  def check_authZ_item(item_id)
    item = Item.where(id: item_id).first
    unless item && (item.user_id == @user.uid || @user.role == 'admin')
      return false
    else
      return true
    end
  end

  def check_admin
    render nothing: true, status: :unauthorized unless @user.role = 'admin'
  end
end
