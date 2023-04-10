require 'rails_helper'

RSpec.describe "FieldsLists", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/fields_lists/show"
      expect(response).to have_http_status(:success)
    end
  end

end
