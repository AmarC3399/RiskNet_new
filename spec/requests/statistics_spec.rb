require 'rails_helper'

RSpec.describe "Statistics", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/statistics/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /list" do
    it "returns http success" do
      get "/statistics/list"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/statistics/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/statistics/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /disable" do
    it "returns http success" do
      get "/statistics/disable"
      expect(response).to have_http_status(:success)
    end
  end

end
