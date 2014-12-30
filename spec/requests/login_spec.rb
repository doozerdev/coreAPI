require "rails_helper"
require "spec_helper"

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
MongoMapper.database = "doozer_development"
MongoMapper.database.collections.each { |c| c.drop_indexes }

session_id = nil

RSpec.describe "SessionsController" do
  describe "GET /api/login/:oauth_token" do
    it "logs in a user with a FB token" do

      @test_users = Koala::Facebook::TestUsers.new(
      :app_id => '1474823829455959', :secret => 'baa64757ee9417802e9f0605b42067f4')
      user = @test_users.create(true)
      fb_oauth_token = user["access_token"]

      get "/api/login/#{fb_oauth_token}", {}, { "Accept" => "application/json" }

      expect(response.status).to eq 201

      session_id = JSON.parse(response.body)['session_id']

      expect(session_id).to match(/[0-9a-f]{32}/)

      expect(@test_users.delete(user['id'])['success']).to eq true
    end
  end

  describe "DELETE /api/logout" do
    it "logs out one user" do
      expect(session_id).to  match(/[0-9a-f]{32}/)

      delete "/api/logout", {}, {"HTTP_SESSION_ID" => session_id}

      expect(response.status).to eq 200

    end
  end

end
