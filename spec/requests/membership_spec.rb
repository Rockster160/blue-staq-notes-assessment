require 'rails_helper'

RSpec.describe "Memberships", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team) }

  before do
    FactoryBot.create(:membership, user: user, team: team)
    sign_in(user)
  end

  describe "POST /teams/:team_id/memberships" do
    it "adds a user to the team by email" do
      target = FactoryBot.create(:user, email: "newbie@example.com")

      expect {
        post "/teams/#{team.id}/memberships", params: { email: "newbie@example.com" }, as: :json
      }.to change(Membership, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(team.reload.users).to include(target)
    end

    it "404s for an unknown email" do
      post "/teams/#{team.id}/memberships", params: { email: "ghost@example.com" }, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "404s adding to a team the current user is not on" do
      other_team = FactoryBot.create(:team)
      target = FactoryBot.create(:user)

      post "/teams/#{other_team.id}/memberships", params: { email: target.email }, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "rejects adding someone already on the team" do
      target = FactoryBot.create(:user)
      FactoryBot.create(:membership, user: target, team: team)

      expect {
        post "/teams/#{team.id}/memberships", params: { email: target.email }, as: :json
      }.not_to change(Membership, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /memberships/:id" do
    it "removes a membership" do
      target = FactoryBot.create(:user)
      membership = FactoryBot.create(:membership, user: target, team: team)

      expect {
        delete "/memberships/#{membership.id}"
      }.to change(Membership, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      expect(team.reload.users).not_to include(target)
    end

    it "404s removing a membership from a team the current user is not on" do
      membership = FactoryBot.create(:membership)

      delete "/memberships/#{membership.id}"
      expect(response).to have_http_status(:not_found)
    end
  end
end
