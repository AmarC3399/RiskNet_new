require 'rails_helper'

RSpec.describe "Rules", type: :request do
  describe "GET /all" do
    it "returns http success" do
      get "/rules/all"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/rules/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/rules/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/rules/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/rules/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /disable" do
    it "returns http success" do
      get "/rules/disable"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /activate" do
    it "returns http success" do
      get "/rules/activate"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /deactivate" do
    it "returns http success" do
      get "/rules/deactivate"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /live" do
    it "returns http success" do
      get "/rules/live"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /authorisation_ids" do
    it "returns http success" do
      get "/rules/authorisation_ids"
      expect(response).to have_http_status(:success)
    end
  end

end
