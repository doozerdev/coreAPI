class SolutionState
  include MongoMapper::Document

  key :solution_id, String
  key :item_id, String
  key :like, Integer
  key :views, Integer
  key :clicks, Integer
  timestamps!

end
