class Item
  include MongoMapper::Document

  key :title, String
  key :done, Boolean
  key :archive, Boolean
  key :parent, String
  key :order, Integer
  key :duedate, DateTime
  key :user_id, String
  key :notes, String

  def children
    #TODO: cache this
    child_items = Item.where(:parent => id.to_s).order(:order).all
  end
end
