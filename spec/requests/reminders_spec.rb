require 'rails_helper'

RSpec.describe "Reminders", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/reminders/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/reminders/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/reminders/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/reminders/update"
      expect(response).to have_http_status(:success)
    end
  end

end
