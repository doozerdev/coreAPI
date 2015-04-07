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

end
