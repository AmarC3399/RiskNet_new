require 'rails_helper'

RSpec.describe "Alertoverrides", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/alertoverrides/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/alertoverrides/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/alertoverrides/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/alertoverrides/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/alertoverrides/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /deactivate" do
    it "returns http success" do
      get "/alertoverrides/deactivate"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /send_args" do
    it "returns http success" do
      get "/alertoverrides/send_args"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /this_param" do
    it "returns http success" do
      get "/alertoverrides/this_param"
      expect(response).to have_http_status(:success)
    end
  end

end
