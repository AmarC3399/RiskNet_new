require 'rails_helper'

RSpec.describe "ListManagements", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/list_management/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/list_management/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /export" do
    it "returns http success" do
      get "/list_management/export"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /import" do
    it "returns http success" do
      get "/list_management/import"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/list_management/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/list_management/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /disable" do
    it "returns http success" do
      get "/list_management/disable"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /dropdown_list" do
    it "returns http success" do
      get "/list_management/dropdown_list"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /get_list" do
    it "returns http success" do
      get "/list_management/get_list"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /get_default_list" do
    it "returns http success" do
      get "/list_management/get_default_list"
      expect(response).to have_http_status(:success)
    end
  end

end
