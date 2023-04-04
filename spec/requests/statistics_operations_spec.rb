require 'rails_helper'

RSpec.describe "StatisticsOperations", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/statistics_operations/index"
      expect(response).to have_http_status(:success)
    end
  end

end
