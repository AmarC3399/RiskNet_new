require 'rails_helper'

RSpec.describe "Criteria", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/criteria/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/criteria/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /description" do
    it "returns http success" do
      get "/criteria/description"
      expect(response).to have_http_status(:success)
    end
  end

end
