require 'rails_helper'

RSpec.describe "Investigations", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/investigations/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/investigations/create"
      expect(response).to have_http_status(:success)
    end
  end

end
