class ItemSolutionMap
  include MongoMapper::Document

  key :item_id, String
  key :solution_id, String
  key :date_associated, Time
  timestamps!

end
