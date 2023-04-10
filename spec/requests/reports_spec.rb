require 'rails_helper'

RSpec.describe "Reports", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/reports/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/reports/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/reports/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/reports/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /clone" do
    it "returns http success" do
      get "/reports/clone"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /download" do
    it "returns http success" do
      get "/reports/download"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /disable" do
    it "returns http success" do
      get "/reports/disable"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /results" do
    it "returns http success" do
      get "/reports/results"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /execute" do
    it "returns http success" do
      get "/reports/execute"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /disable_result" do
    it "returns http success" do
      get "/reports/disable_result"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /result" do
    it "returns http success" do
      get "/reports/result"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /result_downloads" do
    it "returns http success" do
      get "/reports/result_downloads"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /result_download" do
    it "returns http success" do
      get "/reports/result_download"
      expect(response).to have_http_status(:success)
    end
  end

end
