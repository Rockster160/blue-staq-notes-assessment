require 'rails_helper'

RSpec.describe "Teams", type: :request do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in(user) }

  describe "GET /teams" do
    it "lists only attached teams" do
      mine = FactoryBot.create(:team, name: "Mine")
      FactoryBot.create(:membership, user: user, team: mine)
      FactoryBot.create(:team, name: "Theirs")   # user is not a member

      get "/teams"

      expect(response).to have_http_status(:ok)
      expect(json.map { |t| t[:id] }).to contain_exactly(mine.id)
    end

    it "requires authentication" do
      delete "/session"
      get "/teams"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /teams" do
    it "creates a team and auto adds the owner" do
      expect {
        post "/teams", params: { team: { name: "Engineering" } }, as: :json
      }.to change(Team, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json).to include(name: "Engineering")

      team = Team.find(json[:id])
      expect(team.owner_id).to eq(user.id)
      expect(team.users).to include(user)
    end

    it "rejects a blank name with 422" do
      expect {
        post "/teams", params: { team: { name: "" } }, as: :json
      }.not_to change(Team, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /teams/:id" do
    it "renames a team the user belongs to" do
      team = FactoryBot.create(:team, name: "Old")
      FactoryBot.create(:membership, user: user, team: team)

      patch "/teams/#{team.id}", params: { team: { name: "New" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(team.reload.name).to eq("New")
    end

    it "fails to update a team" do
      team = FactoryBot.create(:team, name: "Not mine")

      patch "/teams/#{team.id}", params: { team: { name: "Hijack" } }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
