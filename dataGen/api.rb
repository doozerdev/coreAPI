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
