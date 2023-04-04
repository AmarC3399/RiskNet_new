require 'rails_helper'

RSpec.describe "AlertOverrides", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/alert_overrides/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/alert_overrides/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/alert_overrides/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/alert_overrides/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /deactivate" do
    it "returns http success" do
      get "/alert_overrides/deactivate"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /send_args" do
    it "returns http success" do
      get "/alert_overrides/send_args"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /this_param" do
    it "returns http success" do
      get "/alert_overrides/this_param"
      expect(response).to have_http_status(:success)
    end
  end

end
