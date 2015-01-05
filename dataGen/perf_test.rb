require 'httparty'

class Doozer
  include HTTParty
  base_uri 'localhost:3000'

  def login (fb_oauth_token)
    response = self.class.get("/api/login/#{fb_oauth_token}")

    if response.code == 401
      response.code
    else
      JSON.parse(response.body)['session_id']
    end
  end

  def logout (session_id)
    options = {
      headers: {
        "session_id" => session_id,
      }
    }
    self.class.delete( '/api/logout', options )
  end

  def getLists (session_id)
    options = {
      headers: {
        "session_id" => session_id,
      }
    }
    response = self.class.get( '/api/items/index', options)
    parseResponse(response)
  end

  def getChildren (session_id, item_id)
    options = {
      headers: {
        "session_id" => session_id,
      }
    }

    parseResponse(self.class.get( "/api/items/#{item_id}/children", options ))
  end

  def createItem (session_id, parent_id, title, notes, order, due_date, done, archive)
    options = {
      headers: {
        "session_id" => session_id,
      },
      body: {
        parent: parent_id,
        title: title,
        notes: notes,
        order: order,
        duedate: due_date,
        done: done,
        archive: archive
      }
    }
    parseResponse(self.class.post( '/api/items/create', options))
  end

  def getItem (session_id, item_id)
    options = {
      headers: {
        "session_id" => session_id,
      }
    }
    parseResponse(self.class.get( "/api/items/#{item_id}/show", options))
  end

  def updateItem (session_id, item_id, parent_id, title, notes, order, due_date, done, archive)
    options = {
      headers: {
        "session_id" => session_id,
      },
      body: {
        item_id: item_id,
        parent: parent_id,
        title: title,
        notes: notes,
        order: order,
        duedate: due_date,
        done: done,
        archive: archive
      }
    }
    parseResponse(self.class.put( "/api/items/#{item_id}", options))
  end

  def deleteItem (session_id, item_id)
    options = {
      headers: {
        "session_id" => session_id,
      }
    }
    response = self.class.delete( "/api/items/#{item_id}", options)
    if response.code == 401
      return response.code, nil
    else
      return response.code, response['delete_item_count']
    end
  end

  private
  def parseResponse(response)
    if response.code == 401
      return response.code, nil
    else
      return response.code, JSON.parse(response.body)
    end
  end
end

def main
  start_time = Time.now
  # fb_oauth_token = 'CAAU9WC52BFcBAG4ISr5tjKnLkYvxVlIBk4L8lMdIpM1eubebabkgcp1aAXbgAawr3Kc16B5SZBxmPJZCgP1AemZAYihfSWFa6I5ScAiqwHXbtZA45Xo7ZBfnVaqnzo3ffuZAqJqRIKZBsQOzgpbeIr4qR1C2ydFtE6QCKdZAG0RxBjKFFpqmMEvSBxQd6DZBebmN4z1nTlZApmnLVZBZAiedhA1i'

  doozer = Doozer.new()
  # session_id = doozer.login(fb_oauth_token)
  # puts session_id
  session_id = 'f40e53dac45612ae2d26256a3beb2c6bedb2462dd29f750d5a25daff982c096b'
  num_items = 50

  items = Array.new
  read_items = Array.new
  update_items = Array.new

  #Create
  create_start = Time.now
  for i in 1..num_items
    code, item = doozer.createItem(session_id, nil,
                      "title - #{i}", '', '', nil, false, false)
    items.push item
  end
  create_end = Time.now

  #Read
  read_start = Time.now
  items.each do |i|
    code, item = doozer.getItem(session_id, i['id'])
    read_items.push item
  end
  read_end = Time.now

  #Update
  update_start = Time.now
  items.each do |i|
    code, item = doozer.updateItem(session_id, i['id'], nil, "updated title - #{i}", '', '', nil, true, false )
  end
  update_end = Time.now

  #Delete
  delete_start = Time.now
  items.each do |i|
    code, num_deleted =  doozer.deleteItem(session_id, i['id'])
  end
  delete_end = Time.now

  end_time = Time.now
  puts "create #{(create_end-create_start)*1000}"
  puts "read #{(read_end-read_start)*1000}"
  puts "update #{(update_end-update_start)*1000}"
  puts "delete #{(delete_end-delete_start)*1000}"
  puts "overall: #{(end_time-start_time)*1000}"
end

main()
