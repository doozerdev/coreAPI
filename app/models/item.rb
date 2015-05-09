class Item
  include MongoMapper::Document

  key :title, String
  key :done, Boolean
  key :archive, Boolean
  key :parent, String
  key :order, Integer
  key :duedate, Time
  key :user_id, String
  key :notes, String
  key :solutions, String
  timestamps!

  Item.ensure_index ([[:title, 1]])

  def children
    #TODO: cache this
    child_items = Item.where(:parent => id.to_s, :archive => [false, nil]).order(:order).all
  end

  def as_json(options = { })
    h = super(options)
    h[:children_count] = children.count
    h[:children_undone] = children.count {|item| !item.done}
    h
  end

end
