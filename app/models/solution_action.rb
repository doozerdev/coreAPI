class SolutionAction
  include MongoMapper::Document

  #1:like(5), 2:dislike(-5), 3:clicked(8), 4:viewed(3)
  key :action_name, String
  key :action_value, Integer
end
