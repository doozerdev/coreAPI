class ItemSolutionMap
  include MongoMapper::Document

  key :item_id, String
  key :solution_id, String
  key :linked, Boolean
  timestamps!

end
