require 'rails_helper'

RSpec.describe "Journals", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/journals/index"
      expect(response).to have_http_status(:success)
    end
  end

end
