require 'rails_helper'

RSpec.describe "Clients", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/clients/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/clients/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/clients/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/clients/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/clients/update"
      expect(response).to have_http_status(:success)
    end
  end

end
