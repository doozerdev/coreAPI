class ItemSolutionMap
  include MongoMapper::Document

  key :user_id, String
  key :item_id, String
  key :solution_id, String
  key :linked, Boolean
  timestamps!

end
