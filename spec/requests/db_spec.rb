require 'rails_helper'

RSpec.describe "Dbs", type: :request do
  describe "GET /savepoint" do
    it "returns http success" do
      get "/db/savepoint"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /rollback" do
    it "returns http success" do
      get "/db/rollback"
      expect(response).to have_http_status(:success)
    end
  end

end
