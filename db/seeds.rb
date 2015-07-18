# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

SolutionAction.create([
  {_id: 1, action_name: 'like', action_value: 5},
  {_id: 2, action_name: 'dislike', action_value: -5},
  {_id: 3, action_name: 'click', action_value: 8},
  {_id: 4, action_name: 'viewed', action_value: 3}
])
