require "rails_helper"
require "spec_helper"

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017)
MongoMapper.database = "doozer_development"
MongoMapper.database.collections.each { |c| c.drop_indexes }

session_id = nil

RSpec.describe "SessionsController" do
  describe "GET /api/login/:oauth_token" do
    it "logs in a user with a FB token" do

      fb_oauth_token = 'CAAU9WC52BFcBADYVzRsGquuWlt45fkR6xWR63TUhO35OEGyLUhAdp07Nb38vO7uDJzdZAHqEKXpmGT6JHubHvHlgYVUTzWCZCdAK1RwVQlEDSNDF0uW0CWCMpIB6cC5K4H1SENgHfNgeYab8VEcdmL5JSNJLPznY6NtukZBd9uBJPVlxOK3IQXs9jJaSNVcRBccXHqSwPXre50h1yBp'

      get "/api/login/#{fb_oauth_token}", {}, { "Accept" => "application/json" }

      # get "/api/login/#{fb_oauth_token}"

      expect(response.status).to eq 201

      session_id = JSON.parse(response.body)['session_id']

      expect(session_id).to match(/[0-9a-f]{32}/)
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
