require "rails_helper"
require "spec_helper"

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
MongoMapper.database = "doozer_development"
MongoMapper.database.collections.each { |c| c.drop_indexes }

session_id = nil

RSpec.describe "Lists API" do

  new_list_id = nil
  first_item_id = nil

  before(:all) do
    user = Koala::Facebook::TestUsers.new(:app_id => '1474823829455959', :secret => 'baa64757ee9417802e9f0605b42067f4').list.select{|user| user['id'] == '321638971355001'}.first

    fb_oauth_token = user["access_token"]

    get "/api/login/#{fb_oauth_token}", {}, { "Accept" => "application/json" }

    expect(response.status).to eq 201

    session_id = JSON.parse(response.body)['session_id']

    expect(session_id).to match(/[0-9a-f]{32}/)
  end

  describe "POST /api/lists/create" do
    it "create a new list" do

      post "/api/items/create", {
        :title => 'A New List',
        :notes => 'Some Notes',
      },
        {"HTTP_SESSION_ID" => session_id}

      expect(response.status).to eq 201

      item = JSON.parse(response.body)

      expect(item['title']).to eq 'A New List'
      expect(item['notes']).to eq 'Some Notes'
      new_list_id = item['id']
    end

    it "adds two items to the newly created list" do
      post "/api/items/create", {
        :parent => new_list_id,
        :title => 'The First Item for the List',
        :notes => 'Some Notes',
      },
        {"HTTP_SESSION_ID" => session_id}

      expect(response.status).to eq 201

      child = JSON.parse(response.body)

      expect(child['title']).to eq 'The First Item for the List'
      expect(child['notes']).to eq 'Some Notes'
      first_item_id = child['id']

      post "/api/items/create", {
        :parent => new_list_id,
        :title => 'The Second Item for the List',
        :notes => 'Some Notes',
      },
        {"HTTP_SESSION_ID" => session_id}

      expect(response.status).to eq 201

      child = JSON.parse(response.body)

      expect(child['title']).to eq 'The Second Item for the List'
      expect(child['notes']).to eq 'Some Notes'
    end
  end


  describe "GET /api/lists/index" do
    it "retrieves all lists for test user" do
      get "/api/items/index", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      items = JSON.parse(response.body)['items']
      expect(items.count).to eq 1
      list = items[0]
      expect(list['id']).to eq new_list_id
      expect(list['title']).to eq 'A New List'
      expect(list['notes']).to eq 'Some Notes'
    end
  end

  describe "GET /api/lists/:id/children" do
    it "retrieves all chilren nodes for the newly created list" do
      get "/api/items/#{new_list_id}/children", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      children = JSON.parse(response.body)['items']
      expect(children.count).to eq 2


      expect(children[0]['title']).to eq 'The First Item for the List'
      expect(children[0]['notes']).to eq 'Some Notes'

      expect(children[1]['title']).to eq 'The Second Item for the List'
      expect(children[1]['notes']).to eq 'Some Notes'
    end
  end

  describe "DELETE /api/lists/:id" do
    it "deletes one item from the list" do
      delete "/api/items/#{first_item_id}", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      delete_count = JSON.parse(response.body)['delete_item_count']
      expect(delete_count).to eq 1
    end
  end

  describe "DELETE /api/lists/:id" do
    it "deletes the entire newly created list" do
      delete "/api/items/#{new_list_id}", {}, {"HTTP_SESSION_ID" => session_id}
      expect(response.status).to eq 200
      delete_count = JSON.parse(response.body)['delete_item_count']
      expect(delete_count).to eq 2
    end
  end


end
