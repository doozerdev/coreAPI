# this is a basic test harness to demonstrate the functionality of the
# doozer API. Not the same as a proper test harness, but can be useful for
# testing and debugging.
# call it from the command line using 'ruby main.rb'


require './api.rb'

fb_oauth_token = 'CAAU9WC52BFcBAOkmLpZAbdxulZAiAc8MBcod3IxgJ6xqnk7B1hCSmS6nDxBpIZBhfn5ccQkbUXowHfGzFpYskN9EJLq2GS3kQVqpDyctRAmGzldxg5zZC8kcIc05vW2zlJCMyUsQ9VeoCx15vJnYwr8iU3vQMSMyAyMqPmpxPHm0XHjT1wzBkWPp2dBMhg5UplR3GasW1xzaZBF8DnXOQ'

def checkResponse(code)
  if code == 401
    puts "login to Doozer Failed code #{code}. Exiting."
    exit
  end
end

def main (verbose)

  verbs = ['accept', 'allow', 'ask', 'believe', 'borrow', 'break', 'bring', 'buy', 'cancel', 'change', 'clean', 'comb', 'complain', 'cough', 'count', 'cut', 'dance', 'draw', 'drink', 'drive', 'eat', 'explain', 'fall', 'fill', 'find', 'finish', 'fit', 'fix', 'fly', 'forget', 'give', 'go', 'have', 'hear', 'hurt', 'know', 'learn', 'leave', 'listen', 'live', 'look', 'lose', 'make', 'need', 'open']

  nouns = ['time', 'year', 'people', 'way', 'day', 'man', 'thing', 'woman', 'life', 'child', 'world', 'school', 'state', 'family', 'student', 'group', 'country', 'problem', 'hand', 'part', 'place', 'case', 'week', 'company', 'system', 'program', 'question', 'work', 'government', 'number', 'night', 'point', 'home', 'water', 'room', 'mother', 'area', 'money', 'story', 'fact', 'month', 'lot', 'right', 'study', 'book', 'eye', 'job', 'word', 'business', 'issue', 'side', 'kind', 'head', 'house', 'service', 'friend', 'father', 'power', 'hour', 'game', 'line', 'end', 'member', 'law', 'car', 'city', 'community', 'name', 'president', 'team', 'minute', 'idea', 'kid', 'body', 'information', 'back', 'parent', 'face', 'others', 'level', 'office', 'door', 'health', 'person', 'art', 'war', 'history', 'party', 'result', 'change', 'morning', 'reason', 'research', 'girl', 'guy', 'moment', 'air', 'teacher', 'force', 'education']

  item_ids = Array.new()
  list_ids = Array.new()
  newly_created_item_ids = Array.new()
  newly_created_list_ids = Array.new()

  doozer = Doozer.new()

  ###################################
  #log in
  ###################################
  if verbose
    puts '####################################'
    puts 'Login'
    puts '------------------------------------'
  end
  session_id = doozer.login(fb_oauth_token)

  if session_id == 401
    puts 'unauthorized from FaceBook, be sure to replace the oauth token. Exiting'
    exit
  end
  if verbose
    puts "session_id: #{session_id}"
  end


  start_time = Time.now
  ###################################
  #Get Lists
  ###################################
  if verbose
    puts '####################################'
    puts 'getLists'
    puts '------------------------------------'
  end
  code, lists = doozer.getLists(session_id)
  checkResponse(code)

  # delete everything
  # lists["items"].each do |list|
  #   code, num_deleted =  doozer.deleteItem(session_id, list['id'])
  #   puts "deleted #{num_deleted} items (including list)"
  # end


  lists["items"].each do |list|
    if verbose
      puts "#{list['title']} - #{list['id']}"
    end
    list_ids.push(list['id'])
  end

  ###################################
  #Get Children
  ###################################
  if verbose
    puts '####################################'
    puts 'getChildren'
    puts '------------------------------------'
  end
  list_ids.each do |list_id|
    code, item = doozer.getItem(session_id, list_id)
    if verbose
      puts item['title']
    end
    code, children = doozer.getChildren(session_id, list_id)

    if children['items'].any?
      children['items'].each do |item|
        if verbose
          puts "  #{item['title']} - #{item['id']}"
        end
        item_ids.push(item['id'])
      end
    else
      if verbose
        puts '  no children'
      end
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
  if verbose
    puts 'created new list'

    code, item = doozer.getItem(session_id, new_list['id'])
    puts item['title']

    code, children = doozer.getChildren(session_id, new_list['id'])
    children['items'].each do |item|
      puts "  #{item['title']} - #{item['id']}"
    end
  end
  ###################################
  #Update Item
  ###################################
  if verbose
    puts 'update 2 random list titles'
  end
  for i in 1..2
    code, list = doozer.getItem(session_id, newly_created_list_ids.sample)

    code, updated_list = doozer.updateItem(session_id, list['id'], list['parent'], "updated title - #{list['title']}", list['notes'], list['order'], list['duedate'], list['done'], list['archive'] )
    if verbose
      puts 'list was: '
      puts list['title']
      puts 'list updated to: '
      puts updated_list['title']
    end
  end
  if verbose
    puts 'update 10 random item titles'
  end
  for i in 1..10
    code, item = doozer.getItem(session_id, newly_created_item_ids.sample)

    code, updated_item = doozer.updateItem(session_id, item['id'], item['parent'], "updated title - #{item['title']}", item['notes'], item['order'], item['duedate'], item['done'], item['archive'] )
    if verbose
      puts 'item was: '
      puts item['title']
      puts 'item updated to: '
      puts updated_item['title']
    end
  end



  ###################################
  #Delete Item
  ###################################
  if verbose
    puts 'delete one random list (and all children)'
  end
  to_delete = newly_created_list_ids.sample
  code, response = doozer.getChildren(session_id, to_delete)
  children = response['items']

  items_to_delete = children.map{|c| c['id']}
  newly_created_item_ids.delete(items_to_delete)
  newly_created_list_ids.delete(to_delete)
  code, num_deleted =  doozer.deleteItem(session_id, to_delete)
  if verbose
    puts "deleted #{num_deleted} items (including list)"
  end
  num_to_delete = rand(5)
  if verbose
    puts "delete #{num_to_delete} random items"
  end
  for i in 1..num_to_delete
    item_id = newly_created_item_ids.sample
    if verbose
      puts "======Deleteing #{item_id}"
    end
    newly_created_item_ids.delete(item_id)
    code, num_deleted = doozer.deleteItem(session_id, item_id)
  end
  if verbose
    puts 'deleting all other test lists created by running this script.'
  end
  newly_created_list_ids.each do |to_delete|
    newly_created_list_ids.delete(to_delete)
    code, num_deleted =  doozer.deleteItem(session_id, to_delete)
    if verbose
      puts "deleted #{num_deleted} items (including list)"
    end
  end

  end_time = Time.now

  ###################################
  #log out
  ###################################
  if verbose
    puts '####################################'
    puts 'log out'
    puts '------------------------------------'
  end
  logout_code = doozer.logout(session_id).code
  if verbose
    puts "  log out: #{logout_code}"
  end

  return (end_time-start_time)*1000
end

timings = Array.new
for i in 1..4
  puts main(false)
end

