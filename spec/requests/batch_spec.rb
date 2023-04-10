require 'rails_helper'

RSpec.describe "Batches", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/batch/index"
      expect(response).to have_http_status(:success)
    end
  end

end
