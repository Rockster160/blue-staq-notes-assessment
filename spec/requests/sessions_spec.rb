require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:user) { FactoryBot.create(:user) }

  describe "POST /session" do
    it "logs in with good credentials" do
      sign_in(user)

      expect(response).to have_http_status(:created)
      expect(json).to include(email: "user1@example.com")
    end

    it "rejects bad credentials with 401" do
      post "/session", params: { email: user.email, password: "wrong" }, as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "blocks authenticated endpoints unless signed in" do
      get "/teams"
      expect(response).to have_http_status(:unauthorized)

      sign_in(user)
      get "/teams"
      expect(response).to have_http_status(:ok)
    end

    it "can log out" do
      sign_in(user)
      delete "/session"
      expect(response).to have_http_status(:no_content)

      get "/teams"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
