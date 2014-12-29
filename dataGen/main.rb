# this is a basic test harness to demonstrate the functionality of the 
# doozer API. Not the same as a proper test harness, but can be useful for 
# testing and debugging.
# call it from the command line using 'ruby main.rb'


require './api.rb'

def checkResponse(code)
  if code == 401
    puts "login to Doozer Failed code #{code}. Exiting."
    exit
  end
end

def main

  verbs = ['accept', 'allow', 'ask', 'believe', 'borrow', 'break', 'bring', 'buy', 'cancel', 'change', 'clean', 'comb', 'complain', 'cough', 'count', 'cut', 'dance', 'draw', 'drink', 'drive', 'eat', 'explain', 'fall', 'fill', 'find', 'finish', 'fit', 'fix', 'fly', 'forget', 'give', 'go', 'have', 'hear', 'hurt', 'know', 'learn', 'leave', 'listen', 'live', 'look', 'lose', 'make', 'need', 'open']

  nouns = ['time', 'year', 'people', 'way', 'day', 'man', 'thing', 'woman', 'life', 'child', 'world', 'school', 'state', 'family', 'student', 'group', 'country', 'problem', 'hand', 'part', 'place', 'case', 'week', 'company', 'system', 'program', 'question', 'work', 'government', 'number', 'night', 'point', 'home', 'water', 'room', 'mother', 'area', 'money', 'story', 'fact', 'month', 'lot', 'right', 'study', 'book', 'eye', 'job', 'word', 'business', 'issue', 'side', 'kind', 'head', 'house', 'service', 'friend', 'father', 'power', 'hour', 'game', 'line', 'end', 'member', 'law', 'car', 'city', 'community', 'name', 'president', 'team', 'minute', 'idea', 'kid', 'body', 'information', 'back', 'parent', 'face', 'others', 'level', 'office', 'door', 'health', 'person', 'art', 'war', 'history', 'party', 'result', 'change', 'morning', 'reason', 'research', 'girl', 'guy', 'moment', 'air', 'teacher', 'force', 'education']

  item_ids = Array.new()
  list_ids = Array.new()
  newly_created_item_ids = Array.new()
  newly_created_list_ids = Array.new()

  doozer = Doozer.new()

  fb_oauth_token = 'CAAU9WC52BFcBADZBm9F1usPm2MzH5zx0P1maYfA6bG4EdULPLTDUH1W7LGP9zP21DXw2fkp2tN8R9hqXgbC0I4vHfk0uhP2LZCt1JZCDGDW7TGu4EZCiPtqYCPtIDzTUnTizeAPfumMdflw7AKwN7yY5VYz6I4peAZBiUVpalHDsbNkOPfxo2FeoDUQZCrY0DtUltlQlAmtLoYZAAqm8cEw'

  ###################################
  #log in
  ###################################
  puts '####################################'
  puts 'Login'
  puts '------------------------------------'
  session_id = doozer.login(fb_oauth_token)

  if session_id == 401
    puts 'unauthorized from FaceBook, be sure to replace the oauth token. Exiting'
    exit
  end

  puts "session_id: #{session_id}"

  ###################################
  #Get Lists
  ###################################
  puts '####################################'
  puts 'getLists'
  puts '------------------------------------'
  code, lists = doozer.getLists(session_id)
  checkResponse(code)

  # delete everything
  # lists["items"].each do |list|
  #   code, num_deleted =  doozer.deleteItem(session_id, list['id'])
  #   puts "deleted #{num_deleted} items (including list)"
  # end


  lists["items"].each do |list|
    puts "#{list['title']} - #{list['id']}"
    list_ids.push(list['id'])
  end

  ###################################
  #Get Children
  ###################################
  puts '####################################'
  puts 'getChildren'
  puts '------------------------------------'
  list_ids.each do |list_id|
    code, item = doozer.getItem(session_id, list_id)

    puts item['title']

    code, children = doozer.getChildren(session_id, list_id)

    if children['items'].any?
      children['items'].each do |item|
        puts "  #{item['title']} - #{item['id']}"
        item_ids.push(item['id'])
      end
    else
      puts '  no children'
    end
  end

  ###################################
  #Create List
  ###################################
  code, new_list = doozer.createItem(session_id, nil,
                                     "#{verbs.sample} #{nouns.sample}", '', '', nil, false, false)

  newly_created_list_ids.push(new_list['id'])


  ###################################
  #Create Item for List
  ###################################

  for i in 1..rand(200)
    code, item = doozer.createItem(session_id, new_list['id'],
                                   "#{verbs.sample} #{nouns.sample}", '', '', nil, false, false)

    newly_created_item_ids.push(item['id'])
  end

  puts 'created new list'

  code, item = doozer.getItem(session_id, new_list['id'])
  puts item['title']

  code, children = doozer.getChildren(session_id, new_list['id'])

  children['items'].each do |item|
    puts "  #{item['title']} - #{item['id']}"
  end

  ###################################
  #Update Item
  ###################################

  puts 'update 2 random list titles'
  for i in 1..2
    code, list = doozer.getItem(session_id, newly_created_list_ids.sample)

    code, updated_list = doozer.updateItem(session_id, list['id'], list['parent'], "updated title - #{list['title']}", list['notes'], list['order'], list['duedate'], list['done'], list['archive'] )

    puts 'list was: '
    puts list['title']
    puts 'list updated to: '
    puts updated_list['title']
  end

  puts 'update 10 random item titles'
  for i in 1..10
    code, item = doozer.getItem(session_id, newly_created_item_ids.sample)

    code, updated_item = doozer.updateItem(session_id, item['id'], item['parent'], "updated title - #{item['title']}", item['notes'], item['order'], item['duedate'], item['done'], item['archive'] )

    puts 'item was: '
    puts item['title']
    puts 'item updated to: '
    puts updated_item['title']
  end



  ###################################
  #Delete Item
  ###################################

  puts 'delete one random list (and all children)'
  to_delete = newly_created_list_ids.sample
  code, response = doozer.getChildren(session_id, to_delete)
  children = response['items']

  items_to_delete = children.map{|c| c['id']}
  newly_created_item_ids.delete(items_to_delete)
  newly_created_list_ids.delete(to_delete)
  code, num_deleted =  doozer.deleteItem(session_id, to_delete)
  puts "deleted #{num_deleted} items (including list)"

  num_to_delete = rand(5)
  puts "delete #{num_to_delete} random items"
  for i in 1..num_to_delete
    item_id = newly_created_item_ids.sample
    puts "======Deleteing #{item_id}"
    newly_created_item_ids.delete(item_id)
    code, num_deleted = doozer.deleteItem(session_id, item_id)
  end

  puts 'deleting all other test lists created by running this script.'
  newly_created_list_ids.each do |to_delete|
  newly_created_list_ids.delete(to_delete)
  code, num_deleted =  doozer.deleteItem(session_id, to_delete)
  puts "deleted #{num_deleted} items (including list)"
  end

  ###################################
  #log out
  ###################################
  puts '####################################'
  puts 'log out'
  puts '------------------------------------'
  logout_code = doozer.logout(session_id).code

  puts "log out: #{logout_code}"
end

main()
