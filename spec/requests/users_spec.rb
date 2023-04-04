require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/users/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /forwardable" do
    it "returns http success" do
      get "/users/forwardable"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /verify_user" do
    it "returns http success" do
      get "/users/verify_user"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/users/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/users/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/users/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /block" do
    it "returns http success" do
      get "/users/block"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /unblock" do
    it "returns http success" do
      get "/users/unblock"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update_password" do
    it "returns http success" do
      get "/users/update_password"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /installations" do
    it "returns http success" do
      get "/users/installations"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /members" do
    it "returns http success" do
      get "/users/members"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /clients" do
    it "returns http success" do
      get "/users/clients"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /merchants" do
    it "returns http success" do
      get "/users/merchants"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /report_users" do
    it "returns http success" do
      get "/users/report_users"
      expect(response).to have_http_status(:success)
    end
  end

end
