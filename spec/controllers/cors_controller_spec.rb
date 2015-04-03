require 'rails_helper'

RSpec.describe CorsController, :type => :controller do

  describe "GET preflight" do
    it "returns http success" do
      get :preflight
      expect(response).to have_http_status(:success)
    end
  end

end
