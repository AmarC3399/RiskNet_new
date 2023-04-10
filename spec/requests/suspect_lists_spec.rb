require 'rails_helper'

RSpec.describe "SuspectLists", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/suspect_lists/create"
      expect(response).to have_http_status(:success)
    end
  end

end
