require "rails_helper"
require "spec_helper"

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
MongoMapper.database = "doozer_development"
MongoMapper.database.collections.each { |c| c.drop_indexes }

RSpec.describe "Lists API" do

  session_id = nil
  admin_session_id = nil
  new_list = Item.new(
    :title => 'A New List',
    :notes => 'Some Notes',
    :duedate => DateTime.now,
    :order => 1,
    :done => false,
    :archive => false
  )
  first_item = Item.new(
    :title=>'The First Item for the List',
    :notes=>'Some notes for the first item',
    :duedate => DateTime.now,
    :order => 1,
    :done => false,
    :archive => false
  )
  second_item = Item.new(
    :title=>'The Second Item for the List',
    :notes=>'Some notes for the second item',
    :duedate => DateTime.now,
    :order => 1,
    :done => false,
    :archive => false
  )

  before(:all) do
    test_users = Koala::Facebook::TestUsers.new(:app_id => '1474823829455959', :secret => 'baa64757ee9417802e9f0605b42067f4').list

    user = test_users.select{|user| user['id'] == '321638971355001'}.first
    fb_oauth_token = user["access_token"]
    get "/api/login/#{fb_oauth_token}", {}, { "Accept" => "application/json" }
    expect(response.status).to eq 201
    session_id = JSON.parse(response.body)['session_id']
    expect(session_id).to match(/[0-9a-f]{32}/)

    admin = test_users.select{|admin| admin['id'] == '1546391385590451'}.first
    fb_oauth_token = admin["access_token"]
    get "/api/login/#{fb_oauth_token}", {}, { "Accept" => "application/json" }
    expect(response.status).to eq 201
    json_response = JSON.parse(response.body)
    expect(User.where(:uid => admin['id']).first.role).to eq 'admin'
    admin_session_id = json_response['session_id']
    expect(admin_session_id).to match(/[0-9a-f]{32}/)

  end

  describe "POST /api/lists/create" do
    it "create a new list" do

      post "/api/items/create", {
        :title => new_list.title,
        :notes => new_list.notes,
        :duedate => new_list.duedate,
        :order => new_list.order,
        :done => new_list.done,
        :archive => new_list.archive
      },
        {"HTTP_SESSION_ID" => session_id}

      expect(response.status).to eq 201

      item = JSON.parse(response.body)

      compare(item, new_list)
      new_list.id = item['id']
      first_item.parent = new_list.id
      second_item.parent = new_list.id
    end
  end

  describe 'GET /api/lists/:id/show' do
    it "verifies the new list was created" do
      get "/api/items/#{new_list.id}/show", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      list = JSON.parse(response.body)
      compare(list, new_list)
    end
  end

  describe 'POST /api/lists/create' do
    it "adds two items to the newly created list" do

      post "/api/items/create", {
        :parent => first_item.parent,
        :title => first_item.title,
        :notes => first_item.notes,
        :duedate => first_item.duedate,
        :order => first_item.order,
        :done => first_item.done,
        :archive => first_item.archive
      },
        {"HTTP_SESSION_ID" => session_id}

      expect(response.status).to eq 201

      child = JSON.parse(response.body)
      compare(child, first_item)
      first_item.id = child['id']

      post "/api/items/create", {
        :parent => second_item.parent,
        :title => second_item.title,
        :notes => second_item.notes,
        :duedate => second_item.duedate,
        :order => second_item.order,
        :done => second_item.done,
        :archive => second_item.archive
      },
        {"HTTP_SESSION_ID" => session_id}

      expect(response.status).to eq 201
      child = JSON.parse(response.body)
      compare(child, second_item)
      second_item.id = child['id']
    end
  end

  describe 'GET /api/lists/:id/show' do
    it "verifies the two items were created" do
      get "/api/items/#{first_item.id}/show", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      list = JSON.parse(response.body)
      compare(list, first_item)

      get "/api/items/#{second_item.id}/show", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      list = JSON.parse(response.body)
      compare(list, second_item)
    end
  end

  describe 'GET /api/lists/index' do
    it "retrieves all lists for test user" do
      get "/api/items/index", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      items = JSON.parse(response.body)['items']

      expect(items.select{|l| l['id'] == new_list.id.to_s}.count).to eq 1
      list = items.select{|l| l['id'] == new_list.id.to_s}.first
      compare(list, new_list)
    end
  end

  describe 'GET /api/lists/:id/children' do
    it "retrieves all chilren nodes for the newly created list" do
      get "/api/items/#{new_list.id}/children", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      children = JSON.parse(response.body)['items']
      expect(children.count).to eq 2

      compare(children[0], first_item)
      compare(children[1], second_item)
    end
  end

  describe 'PUT /api/lists/:id' do
    it 'updates the list' do
      new_list.title = "#{new_list.title} - updated"
      new_list.notes = "#{new_list.notes} - updated"
      new_list.duedate = DateTime.now
      new_list.order = 2
      new_list.done = true
      new_list.archive = true

      put "/api/items/#{new_list.id}", {
        :title => new_list.title,
        :notes => new_list.notes,
        :duedate => new_list.duedate,
        :order => new_list.order,
        :done => new_list.done,
        :archive => new_list.archive
      }, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 202
      item = JSON.parse(response.body)
      compare(item, new_list)
    end
  end

  describe 'GET /api/lists/:id/show' do
    it "verifies the list was properly updated" do
      get "/api/items/#{new_list.id}/show", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      list = JSON.parse(response.body)
      compare(list, new_list)
    end
  end

  describe 'PUT /api/lists/:id' do
    it 'updates the items in the list' do
      first_item.title = "#{first_item.title} - updated"
      first_item.notes = "#{first_item.notes} - updated"
      first_item.duedate = DateTime.now
      first_item.order = 2
      first_item.done = true
      first_item.archive = true

      put "/api/items/#{first_item.id}", {
        :parent => first_item.parent,
        :title => first_item.title,
        :notes => first_item.notes,
        :duedate => first_item.duedate,
        :order => first_item.order,
        :done => first_item.done,
        :archive => first_item.archive
      }, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 202
      item = JSON.parse(response.body)
      compare(item, first_item)

      second_item.title = "#{second_item.title} - updated"
      second_item.notes = "#{second_item.notes} - updated"
      second_item.duedate = DateTime.now
      second_item.order = 2
      second_item.done = true
      second_item.archive = true

      put "/api/items/#{second_item.id}", {
        :parent => second_item.parent,
        :title => second_item.title,
        :notes => second_item.notes,
        :duedate => second_item.duedate,
        :order => second_item.order,
        :done => second_item.done,
        :archive => second_item.archive
      }, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 202
      item = JSON.parse(response.body)
      compare(item, second_item)
    end
  end

  describe 'GET /api/lists/:id/show' do
    it "verifies the two items were properly updated" do
      get "/api/items/#{first_item.id}/show", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      list = JSON.parse(response.body)
      compare(list, first_item)

      get "/api/items/#{second_item.id}/show", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      list = JSON.parse(response.body)
      compare(list, second_item)
    end
  end

  describe 'GET /api/lists/:term/search' do
    it "searchs through items" do
      get "/api/items/title/search", {}, {"HTTP_SESSION_ID" => admin_session_id}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['count']).to be > 1
    end
  end

  describe 'DELETE /api/lists/:id' do
    it "deletes one item from the list" do
      delete "/api/items/#{first_item.id}", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      delete_count = JSON.parse(response.body)['delete_item_count']
      expect(delete_count).to eq 1
    end
  end

  describe 'DELETE /api/lists/:id' do
    it "deletes the entire newly created list" do
      delete "/api/items/#{new_list.id}", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      delete_count = JSON.parse(response.body)['delete_item_count']
      expect(delete_count).to eq 2
    end
  end


  ################################################
  #Error Cases
  ################################################

  #does not exist item
  dne_item_id = '123'
  #does not own item
  dno_item_id = '123'
  # a test item we do own, so we can attempt to take over another list
  test_item_id = nil

  describe "POST /api/lists/create" do
    it "create a test item for ownership tests" do
      post "/api/items/create", {
        :title => 'test item'
        },{"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 201
      item = JSON.parse(response.body)
      expect(item['id']).to match(/[a-f0-9]{24}/)
      test_item_id = item['id']
    end
  end  

  describe "POST /api/lists/create" do
    it "attempts to create an item without a title" do
      post "/api/items/create", {},{"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 400
      expect(JSON.parse(response.body)['error']).to eq 'title is required'
    end
  end

  describe "POST /api/lists/create" do
    it "attempts to create an item with a parent we don't own" do
      post "/api/items/create", {
        :title => 'A Parent I do not own',
        :parent => dno_item_id
      },
        {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'parent not found'
    end
  end

  describe 'PUT /api/lists/:id' do
    it "attempt to update an item we don't own" do
      put "/api/items/#{dno_item_id}", {
        :title => 'title',
        :notes => 'notes',
        :duedate => DateTime.now,
        :order => 123,
        :done => true,
        :archive => true
      }, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'item not found'
    end
  end

  describe 'PUT /api/lists/:id' do
    it 'attempt to update an item that does not exist' do
      put "/api/items/#{dne_item_id}", {
        :title => 'title',
        :notes => 'notes',
        :duedate => DateTime.now,
        :order => 123,
        :done => true,
        :archive => true
      }, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'item not found'
    end
  end

describe 'PUT /api/lists/:id' do
    it "attempt to update an item with a parent we don't own" do
      put "/api/items/#{test_item_id}", {
        :title => 'title',
        :parent => dno_item_id,
        :notes => 'notes',
        :duedate => DateTime.now,
        :order => 123,
        :done => true,
        :archive => true
      }, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'parent not found'
    end
  end

  describe 'PUT /api/lists/:id' do
    it "attempt to update an item with a parent that does not exist" do
      put "/api/items/#{test_item_id}", {
        :title => 'title',
        :parent => dne_item_id,
        :notes => 'notes',
        :duedate => DateTime.now,
        :order => 123,
        :done => true,
        :archive => true
      }, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'parent not found'
    end
  end

  describe "GET /api/items/#{first_item.id}/show" do
    it "attempts to view an item we don't own" do
      get "/api/items/#{dno_item_id}/show", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'item not found'
    end
  end

  describe "GET /api/items/#{first_item.id}/show" do
    it "attempts to view an item that does not exist" do
      get "/api/items/#{dne_item_id}/show", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'item not found'
    end
  end

  describe 'DELETE /api/lists/:id' do
    it "attempts to deletes an item that doesn't exist" do
      delete "/api/items/#{dne_item_id}", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'item not found'
    end
  end

  describe 'DELETE /api/lists/:id' do
    it "attempts to deletes an item that we don't own" do
      delete "/api/items/#{dno_item_id}", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'item not found'
    end
  end

  describe 'DELETE /api/lists/:id' do
    it "delete the test item" do
      delete "/api/items/#{test_item_id}", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      delete_count = JSON.parse(response.body)['delete_item_count']
      expect(delete_count).to eq 1
    end
  end

  #######################################################
  # Helper functions
  #######################################################

  def compare(json_item, item)
    expect(json_item['parent']).to eq item.parent if(item.parent)
    expect(json_item['title']).to eq item.title if(item.title)
    expect(json_item['notes']).to eq item.notes if(item.notes)
    expect(DateTime.parse(json_item['duedate'])).to eq item.duedate if(item.duedate)
    expect(json_item['archive']).to eq item.archive if(item.archive)
    expect(json_item['done']).to eq item.done if(item.done)
  end

end
