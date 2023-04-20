require 'rails_helper'

RSpec.describe "Lists", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/lists/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/lists/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/lists/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /export" do
    it "returns http success" do
      get "/lists/export"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /import" do
    it "returns http success" do
      get "/lists/import"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/lists/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/lists/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /disable" do
    it "returns http success" do
      get "/lists/disable"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /dropdown_list" do
    it "returns http success" do
      get "/lists/dropdown_list"
      expect(response).to have_http_status(:success)
    end
  end

end
