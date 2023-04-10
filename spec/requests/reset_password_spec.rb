require 'rails_helper'

RSpec.describe "ResetPasswords", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/reset_password/index"
      expect(response).to have_http_status(:success)
    end
  end

end
