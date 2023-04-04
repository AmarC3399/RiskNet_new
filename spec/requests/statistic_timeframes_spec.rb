require 'rails_helper'

RSpec.describe "StatisticTimeframes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/statistic_timeframes/index"
      expect(response).to have_http_status(:success)
    end
  end

end
