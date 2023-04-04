require 'rails_helper'

RSpec.describe "Alerts", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/alerts/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /batch_alerts" do
    it "returns http success" do
      get "/alerts/batch_alerts"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/alerts/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /allocated_commnets" do
    it "returns http success" do
      get "/alerts/allocated_commnets"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/alerts/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /batch_update" do
    it "returns http success" do
      get "/alerts/batch_update"
      expect(response).to have_http_status(:success)
    end
  end

end
