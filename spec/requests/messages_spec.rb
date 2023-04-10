require 'rails_helper'

RSpec.describe "Messages", type: :request do
  describe "GET /auths" do
    it "returns http success" do
      get "/messages/auths"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /violations" do
    it "returns http success" do
      get "/messages/violations"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /jpos" do
    it "returns http success" do
      get "/messages/jpos"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /front_end_exception" do
    it "returns http success" do
      get "/messages/front_end_exception"
      expect(response).to have_http_status(:success)
    end
  end

end
