class Item
  include MongoMapper::Document

  key :title, String
  key :done, Boolean
  key :date_completed, Time
  key :archive, Boolean
  key :parent, String
  key :order, Integer
  key :duedate, Time
  key :user_id, String
  key :notes, String
  key :solutions, String
  key :color, String
  key :type, String
  timestamps!

  Item.ensure_index ([[:title, 1]])

  def children
    #TODO: cache this
    Item.where(:parent => id.to_s, :archive => [false, nil]).order(:order).all.reject{|i| i.type =='header'}
  end

  def solutions
    #TODO: cache this
    itemsList = ItemSolutionMap.where(:itemId => id.to_s)
    itemsList.collect{|i| Solution.where(:id=>i.solutionId).first}

  end

  def as_json(options = { })
    h = super(options)
    h[:children_count] = children.count
    h[:children_undone] = children.count {|item| !item.done}
    h[:solutions_count] = solutions.count
    h
  end

end
