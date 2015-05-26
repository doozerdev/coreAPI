class ItemSolutionMap
  include MongoMapper::Document

  key :itemId, String
  key :solutionId, String
  key :dateAssociated, Time
  timestamps!

end
