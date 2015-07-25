class ItemSolutionMap
  include MongoMapper::Document

  key :itemId, String
  key :solutionId, String
  key :date_associated, Time
  timestamps!

end
