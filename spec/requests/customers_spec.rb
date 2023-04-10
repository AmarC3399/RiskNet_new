require 'rails_helper'

RSpec.describe "Customers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/customers/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /member" do
    it "returns http success" do
      get "/customers/member"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /merchants" do
    it "returns http success" do
      get "/customers/merchants"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /client_with_many_merchants" do
    it "returns http success" do
      get "/customers/client_with_many_merchants"
      expect(response).to have_http_status(:success)
    end
  end

end
