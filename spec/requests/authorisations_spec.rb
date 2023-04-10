require 'rails_helper'

RSpec.describe "Authorisations", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/authorisations/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /all" do
    it "returns http success" do
      get "/authorisations/all"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /mark" do
    it "returns http success" do
      get "/authorisations/mark"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /unmark" do
    it "returns http success" do
      get "/authorisations/unmark"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /unused_fields" do
    it "returns http success" do
      get "/authorisations/unused_fields"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /used_fields" do
    it "returns http success" do
      get "/authorisations/used_fields"
      expect(response).to have_http_status(:success)
    end
  end

end
