class SolutionsController < BaseApiController
  before_action :check_authZ, except: [:like, :dislike, :click, :view, :for_user]
  before_action :get_solution_state, only: [:like, :dislike, :click, :view]

  def index
    render json: Solution.all, status: 200
  end

  def for_user

    isms = ItemSolutionMap.where(:user_id => @user.uid)
      

    if params[:last_sync]
      begin
        last_sync = DateTime.parse(params[:last_sync])
      rescue
        last_sync = DateTime.strptime(params[:last_sync], '%s')
      end

      ism_since = isms.select { |ism| DateTime.parse(ism.updated_at.to_s) > last_sync }
      #puts "isms for user: #{ism_since.count}"

      solutions_list =
          ism_since.collect { |ism|
            sol                      = Solution.where(:id => ism.solution_id).first
            sol['date_link_updated'] = ism.updated_at
            sol['linked']            = ism.linked
            sol['item_id']           = ism.item_id
            sol
          }
    end

    render json: { items: solutions_list }, status: 200
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
      render json: { error: 'title is required' }, status: 400
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
    solutionsList = ItemSolutionMap.where(:solution_id => params[:id], :linked => true)
    itemsList     = solutionsList.collect { |s| 
      i = Item.where(:id => s.item_id).first 
      i['date_link_updated'] = s.updated_at
      i
    }
    render json: { items: itemsList }, :status => :ok
  end

  def search
    solutions = nil
    start_time = Time.now
    if @user.role == 'admin'

      solutions = Solution.where(params['field'] => /#{Regexp.escape(params['term'])}/i)

    else
      # add ability to search over solutions attached to your own list
    end
    end_time = Time.now
    render json: { request_time: "#{((end_time - start_time) * 1000).round(2)} ms", count: solutions.count, solutions: solutions}, status: :ok
  end

  def addLink
    ism = ItemSolutionMap.first_or_create(:user_id => Item.find(params[:item_id]).user_id,
                                          :solution_id => params[:id],
                                          :item_id     => params[:item_id])

    ism.linked = true

    if ism.save
      render json: ism, status: :created
    else
      render nothing: true, status: :bad_request
    end
  end

  def removeLink
    ism = ItemSolutionMap.first_or_create(:user_id => Item.find(params[:item_id]).user_id,
                                          :solution_id => params[:id],
                                          :item_id     => params[:item_id])

    ism.linked = false

    if ism.save
      render json: ism, status: :ok
    else
      render nothing: true, status: :bad_request
    end
  end

  def like
    @solution_state.like = 1
    @solution_state.save
    save_action(1)
    render nothing: true, status: :created
  end

  def unlike
    @solution_state.like = 0
    @solution_state.save
    save_action(0)
    render nothing: true, status: :created
  end

  def dislike
    @solution_state.like = -1
    @solution_state.save
    save_action(2)
    render nothing: true, status: :created
  end

  def click
    @solution_state.clicks = @solution_state.clicks + 1
    @solution_state.save
    save_action(3)
    render nothing: true, status: :created
  end

  def view
    @solution_state.views = @solution_state.views + 1
    @solution_state.save
    save_action(4)
    render nothing: true, status: :created
  end

  def performance
    likes    = SolutionActivity.where(:solution_id => params[:id], :action_id => '1').all.uniq { |i|
      "#{i[:user_id]}-#{i[:solution_id]}-#{i[:item_id]}" }.count
    dislikes = SolutionActivity.where(:solution_id => params[:id], :action_id => '2').all.uniq { |i|
      "#{i[:user_id]}-#{i[:solution_id]}-#{i[:item_id]}" }.count
    clicks   = SolutionActivity.where(:solution_id => params[:id], :action_id => '3').count
    views    = SolutionActivity.where(:solution_id => params[:id], :action_id => '4').count

    render json: { likes: likes, dislikes: dislikes, clicks: clicks, views: views, score: 0 }, status: 200
  end

  def state
    solution_state = SolutionState.where(:solution_id => params[:id],
                                         :item_id     => params[:item_id]).first
    if solution_state
      render json: solution_state, status: 200
    else
      render nothing: true, status: 404
    end

  end


  #DELETE /item/:id
  #DeleteItem
  def destroy
    Solution.destroy(params[:id])
    render json: { deleted: true }, status: 200
  end

  private
  def save_action (id)
    solution_activity = SolutionActivity.new(:user_id     => @user.id,
                                             :solution_id => params[:id],
                                             :item_id     => params[:item_id],
                                             :action_id   => id)
    solution_activity.save
  end

  def check_authZ
    unless @user.role == 'admin'
      render nothing: true, status: :unauthorized
    end
  end

  def get_solution_state
    @solution_state        = SolutionState.first_or_create(:solution_id => params[:id],
                                                           :item_id     => params[:item_id])
    @solution_state.like   = 0 if @solution_state.like.nil?
    @solution_state.views  = 0 if @solution_state.views.nil?
    @solution_state.clicks = 0 if @solution_state.clicks.nil?
  end
end
