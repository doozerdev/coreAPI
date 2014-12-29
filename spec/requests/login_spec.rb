require "rails_helper"
require "spec_helper"

RSpec.describe "SessionsController" do
  describe "GET /api/login/:oauth_token" do
    it "logs in a user with a FB token" do

      fb_oauth_token = 'CAAU9WC52BFcBAOnASMkwnaTNhcbYHibhTLV7eGu4Kq5aTaeeh9JHW9f7SqPrJKDcJQgE8Pg5GSG8f3zVPqtIlzR21rpqwv6flZBxnzXpvpYBnpLIAgx3ZBPZAtbEhgQJB6SWBXP04IFH02bf6iZAZCcxRZCSIgJvEfxztQd2cor0LVBtlLGxFZC2XnG3LU2sVFVVnBTD0qxLKGWkyZC0bikJ'

      get "/api/login/#{fb_oauth_token}", {}, { "Accept" => "application/json" }

      # get "/api/login/#{fb_oauth_token}"

      expect(response.status).to eq 201

      session_id = JSON.parse(response.body)['session_id']
      
      expect(session_id).to match(/[0-9a-f]{32}/)
    end
  end
end
