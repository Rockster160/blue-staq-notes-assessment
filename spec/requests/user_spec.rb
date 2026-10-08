require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "POST /users" do
    it "creates a user and returns 201" do
      params = { user: FactoryBot.attributes_for(:user, email: "user@example.com", username: "user") }

      expect {
        post "/users", params: params, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json).to include(email: "user@example.com", username: "user")
      expect(json).to have_key(:id)
    end

    it "never returns the password" do
      post "/users", params: { user: FactoryBot.attributes_for(:user) }, as: :json

      expect(response.body).not_to include("Password1!")
      expect(json).not_to have_key(:password)
      expect(json).not_to have_key(:password_digest)
    end

    it "rejects a password shorter than 8 characters" do
      params = { user: FactoryBot.attributes_for(:user, password: "short") }


      expect {
        post "/users", params: params, as: :json
      }.not_to change(User, :count)


      expect(response).to have_http_status(:unprocessable_content)
      expect(json[:errors]).to be_present
    end

    it "rejects a duplicate email" do
      FactoryBot.create(:user, email: "taken@example.com")
      params = { user: FactoryBot.attributes_for(:user, email: "taken@example.com", username: "someone-else") }

      expect {
        post "/users", params: params, as: :json
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate username" do
      FactoryBot.create(:user, username: "taken")
      params = { user: FactoryBot.attributes_for(:user, username: "taken", email: "fresh@example.com") }

      post "/users", params: params, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a missing username" do
      params = { user: FactoryBot.attributes_for(:user).except(:username) }

      post "/users", params: params, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
