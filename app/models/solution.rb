class Solution
  include MongoMapper::Document

  key :title, String
  key :source, String
  key :description, String
  key :price, Float
  key :address, String
  key :phone_number, String
  key :open_hours, String
  key :link, String
  key :tags, String
  key :expire_date, Time
  key :img_link, String
  key :notes, String
  key :archive, Boolean
  timestamps!

  Item.ensure_index ([[:title, 1]])

  def items
    #TODO: cache this
    itemsList = ItemSolutionMap.where(:solutionId => id.to_s)
    itemsList.collect{|s| Solution.where(:id=>s.itemId).first}
  end

  def as_json(options = { })
    h = super(options)
    h[:items_count] = items.count
    h
  end

end
