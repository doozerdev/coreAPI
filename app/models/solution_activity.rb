class SolutionActivity
  include MongoMapper::Document

  key :user_id, String
  key :solution_id, String
  key :item_id, String
  key :action_id, String
  timestamps!

end
