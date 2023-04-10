require 'rails_helper'

RSpec.describe "Merchants", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/merchants/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/merchants/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/merchants/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/merchants/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/merchants/update"
      expect(response).to have_http_status(:success)
    end
  end

end
