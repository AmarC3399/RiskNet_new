require 'rails_helper'

RSpec.describe "RuleSchedules", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/rule_schedules/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/rule_schedules/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/rule_schedules/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /disable" do
    it "returns http success" do
      get "/rule_schedules/disable"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /resources" do
    it "returns http success" do
      get "/rule_schedules/resources"
      expect(response).to have_http_status(:success)
    end
  end

end
